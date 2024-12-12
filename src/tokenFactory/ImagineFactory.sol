// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {ImagineToken} from "./../token/ImagineToken.sol";

import {IImagineFactory} from "./IImagineFactory.sol";
import {IImagineToken} from "./../token/ImagineToken.sol";

import {Ownable} from "@openzeppelin-contracts-5.1.0/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin-contracts-5.1.0/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin-contracts-5.1.0/utils/Pausable.sol";
import {SignatureChecker} from "@openzeppelin-contracts-5.1.0/utils/cryptography/SignatureChecker.sol";
import {MessageHashUtils} from "@openzeppelin-contracts-5.1.0/utils/cryptography/MessageHashUtils.sol";


contract ImagineFactory is IImagineFactory, Ownable, ReentrancyGuard, Pausable {
    uint256 public totalSupply;
    uint256 public virtualTokenReserves;
    uint256 public virtualCollateralReserves;
    uint256 public feeBasisPoints;
    uint256 public mcUpperLimit;
    uint256 public mcLowerLimit;
    uint256 public tokensMigrationThreshold;
    uint256 public migrationFeeFixed;
    uint256 public poolCreationFee;
    uint256 public dexFeeBasisPoints;

    address public dexTreasury;
    address public treasury;
    address public immutable UNISWAP_V2_ROUTER;
    address public signer;

    mapping(bytes32 => bool) public usedSignatures;
    mapping(address => uint8) public readyForMigration;

    address[] public imagineTokens;

    uint256 private constant MAX_BPS = 2_500;

    constructor(
        uint256 _totalSupply,
        uint256 _virtualTokenReserves,
        uint256 _virtualCollateralReserves,
        uint256 _feeBasisPoints,
        uint256 _dexFeeBasisPoints,
        uint256 _migrationFeeFixed,
        uint256 _poolCreationFee,
        uint256 _mcUpperLimit,
        uint256 _mcLowerLimit,
        uint256 _tokensMigrationThreshold,
        address _treasury,
        address _dexTreasury,
        address _uniswapV2Router,
        address _signer
    ) Ownable(msg.sender) {
        _setConfig(
            _totalSupply,
            _virtualTokenReserves,
            _virtualCollateralReserves,
            _feeBasisPoints,
            _dexFeeBasisPoints,
            _migrationFeeFixed,
            _poolCreationFee,
            _mcUpperLimit,
            _mcLowerLimit,
            _tokensMigrationThreshold,
            _treasury,
            _dexTreasury,
            _signer
        );

        UNISWAP_V2_ROUTER = _uniswapV2Router;
    }


    function pause() external override onlyOwner {
        _pause();
    }

    function unpause() external override onlyOwner {
        _unpause();
    }

    function setConfig(
        uint256 _totalSupply,
        uint256 _virtualTokenReserves,
        uint256 _virtualCollateralReserves,
        uint256 _feeBasisPoints,
        uint256 _dexFeeBasisPoints,
        uint256 _migrationFeeFixed,
        uint256 _poolCreationFee,
        uint256 _mcUpperLimit,
        uint256 _mcLowerLimit,
        uint256 _tokensMigrationThreshold,
        address _treasury,
        address _dexTreasury,
        address _signer
    ) external onlyOwner {
        _setConfig(
            _totalSupply,
            _virtualTokenReserves,
            _virtualCollateralReserves,
            _feeBasisPoints,
            _dexFeeBasisPoints,
            _migrationFeeFixed,
            _poolCreationFee,
            _mcUpperLimit,
            _mcLowerLimit,
            _tokensMigrationThreshold,
            _treasury,
            _dexTreasury,
            _signer
        );
    }

    function createImagineToken(
        string memory _name,
        string memory _symbol,
        string memory _tokenURI,
        uint256 _nonce,
        bytes memory _signature
    ) external whenNotPaused returns (address) {
        _checkSignatureAndStore(_name, _symbol,_tokenURI, _nonce, _signature);
        ImagineToken token = new ImagineToken(
            IImagineToken.ConstructorParams(
                _name,
                _symbol,
                _tokenURI,
                msg.sender, // creator
                totalSupply,
                virtualTokenReserves,
                virtualCollateralReserves,
                feeBasisPoints,
                dexFeeBasisPoints,
                migrationFeeFixed,
                poolCreationFee,
                mcLowerLimit,
                mcUpperLimit,
                tokensMigrationThreshold,
                treasury,
                UNISWAP_V2_ROUTER,
                dexTreasury
            )
        );

        imagineTokens.push(address(token));
        emit NewImagineToken(address(token), msg.sender, _signature);
        return address(token);
    }

    function createImagineTokenAndBuy(
        string memory _name,
        string memory _symbol,
        string memory _tokenURI,
        uint256 _nonce,
        uint256 _tokenAmountMin,
        bytes memory _signature
    ) external payable nonReentrant whenNotPaused returns (address) {
        _checkSignatureAndStore(_name, _symbol,_tokenURI, _nonce, _signature);

        ImagineToken token = new ImagineToken(
            IImagineToken.ConstructorParams(
                _name,
                _symbol,
                _tokenURI,
                msg.sender, // creator
                totalSupply,
                virtualTokenReserves,
                virtualCollateralReserves,
                feeBasisPoints,
                dexFeeBasisPoints,
                migrationFeeFixed,
                poolCreationFee,
                mcLowerLimit,
                mcUpperLimit,
                tokensMigrationThreshold,
                treasury,
                UNISWAP_V2_ROUTER,
                dexTreasury
            )
        );

        (
            uint256 collateralToPayWithFee,
            uint256 helioFee,
            uint256 dexFee
        ) = token.buyExactIn{value: msg.value}(_tokenAmountMin);

        uint256 tokenAmount = token.balanceOf(address(this));
        token.transfer(msg.sender, tokenAmount);

        imagineTokens.push(address(token));
        emit NewImagineTokenAndBuy(
            address(token),
            msg.sender,
            _signature,
            tokenAmount,
            collateralToPayWithFee,
            helioFee,
            dexFee,
            token.getCurveProgressBps()
        );
        return address(token);
    }

    function buyExactOut(
        address _token,
        uint256 _tokenAmount,
        uint256 _maxCollateralAmount
    ) external payable nonReentrant {
        (
            uint256 collateralToPayWithFee,
            uint256 helioFee,
            uint256 dexFee
        ) = IImagineToken(_token).buyExactOut{value: msg.value}(
                _tokenAmount,
                _maxCollateralAmount
            );

        IImagineToken(_token).transfer(msg.sender, _tokenAmount);

        uint256 refund = address(this).balance;
        if (refund > 0) {
            (bool sent, ) = msg.sender.call{value: refund}("");
            if (!sent) revert FailedToSendETH();
        }

        emit BuyExactOut(
            msg.sender,
            _token,
            _tokenAmount,
            ImagineToken(_token).totalSupply() -
                IImagineToken(_token).balanceOf(address(_token)),
            collateralToPayWithFee,
            refund,
            helioFee,
            dexFee,
            IImagineToken(_token).getCurveProgressBps()
        );

        if (ImagineToken(_token).tradingStopped()) {
            readyForMigration[_token] = 1;
            emit MarketcapReached(_token);
        }
    }

    function buyExactIn(
        address _token,
        uint256 _amountOutMin
    ) external payable nonReentrant {
        (
            uint256 collateralToPayWithFee,
            uint256 helioFee,
            uint256 dexFee
        ) = IImagineToken(_token).buyExactIn{value: msg.value}(_amountOutMin);

        uint256 tokensOut = IImagineToken(_token).balanceOf(address(this));
        IImagineToken(_token).transfer(msg.sender, tokensOut);

        uint256 refund = address(this).balance;
        if (refund > 0) {
            (bool sent, ) = msg.sender.call{value: refund}("");
            if (!sent) revert FailedToSendETH();
        }

        emit BuyExactIn(
            msg.sender,
            _token,
            tokensOut,
            ImagineToken(_token).totalSupply() -
                IImagineToken(_token).balanceOf(address(_token)),
            collateralToPayWithFee,
            helioFee,
            dexFee,
            IImagineToken(_token).getCurveProgressBps()
        );

        if (ImagineToken(_token).tradingStopped()) {
            readyForMigration[_token] = 1;
            emit MarketcapReached(_token);
        }
    }

    function sellExactIn(
        address _token,
        uint256 _tokenAmount,
        uint256 _amountCollateralMin
    ) external nonReentrant {
        ImagineToken(_token).transferFrom(
            msg.sender,
            address(this),
            _tokenAmount
        );
        (
            uint256 collateralToReceiveMinusFee,
            uint256 helioFee,
            uint256 dexFee
        ) = ImagineToken(_token).sellExactIn(
                _tokenAmount,
                _amountCollateralMin
            );

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        if (!sent) revert FailedToSendETH();

        emit SellExactIn(
            msg.sender,
            _token,
            _tokenAmount,
            ImagineToken(_token).totalSupply() -
                ImagineToken(_token).balanceOf(address(_token)),
            collateralToReceiveMinusFee,
            helioFee,
            dexFee,
            IImagineToken(_token).getCurveProgressBps()
        );
    }

    function sellExactOut(
        address _token,
        uint256 _tokenAmountMax,
        uint256 _amountCollateral
    ) external nonReentrant {
        ImagineToken(_token).transferFrom(
            msg.sender,
            address(this),
            _tokenAmountMax
        );
        (
            uint256 collateralToReceiveMinusFee,
            uint256 tokensOut,
            uint256 helioFee,
            uint256 dexFee
        ) = ImagineToken(_token).sellExactOut(
                _tokenAmountMax,
                _amountCollateral
            );

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        if (!sent) revert FailedToSendETH();

        emit SellExactOut(
            msg.sender,
            _token,
            tokensOut,
            ImagineToken(_token).totalSupply() -
                ImagineToken(_token).balanceOf(address(_token)),
            collateralToReceiveMinusFee,
            helioFee,
            dexFee,
            IImagineToken(_token).getCurveProgressBps()
        );
    }

    function migrate(address _token) external {
        if (readyForMigration[_token] == 0) revert NotReadyForMigration();

        if (readyForMigration[_token] == 2) revert MigratedBefore();

        readyForMigration[_token] = 2;

        (
            uint256 tokensToMigrate,
            uint256 tokensToBurn,
            uint256 collateralAmount
        ) = ImagineToken(_token).migrate();
        emit Migrated(
            _token,
            tokensToMigrate,
            tokensToBurn,
            collateralAmount,
            ImagineToken(_token).fixedMigrationFee() +
                ImagineToken(_token).poolCreationFee(),
            ImagineToken(_token).pair()
        );
    }

    function _setConfig(
        uint256 _totalSupply,
        uint256 _virtualTokenReserves,
        uint256 _virtualCollateralReserves,
        uint256 _feeBasisPoints,
        uint256 _dexFeeBasisPoints,
        uint256 _migrationFeeFixed,
        uint256 _poolCreationFee,
        uint256 _mcUpperLimit,
        uint256 _mcLowerLimit,
        uint256 _tokensMigrationThreshold,
        address _treasury,
        address _dexTreasury,
        address _signer
    ) internal {
        if (_totalSupply == 0) revert TotalSupplyZeroValue();
        if (_virtualTokenReserves == 0) revert VirtualTokenReservesZeroValue();
        if (_virtualCollateralReserves == 0)
            revert VirtualCollateralReservesZeroValue();
        if (_mcLowerLimit == 0) revert McUpperLimitZeroValue();
        if (_mcUpperLimit == 0) revert McLowerLimitZeroValue();
        if (_tokensMigrationThreshold == 0)
            revert TokensMigrationThresholdZeroValue();
        if (_treasury == address(0)) revert TreasuryZeroValue();
        if (_dexTreasury == address(0)) revert DexTreasuryZeroValue();
        if (_signer == address(0)) revert SignerZeroValue();
        if (_mcLowerLimit >= _mcUpperLimit)
            revert McLowerLimitGreaterThanUpperLimit();
        if (dexFeeBasisPoints >= 10_000) revert FeeBPSCheckFailed();
        if (feeBasisPoints >= MAX_BPS) revert FeeBPSCheckFailed();

        totalSupply = _totalSupply;
        virtualTokenReserves = _virtualTokenReserves;
        virtualCollateralReserves = _virtualCollateralReserves;
        feeBasisPoints = _feeBasisPoints;
        dexFeeBasisPoints = _dexFeeBasisPoints;
        migrationFeeFixed = _migrationFeeFixed;
        poolCreationFee = _poolCreationFee;
        mcUpperLimit = _mcUpperLimit;
        mcLowerLimit = _mcLowerLimit;
        tokensMigrationThreshold = _tokensMigrationThreshold;
        treasury = _treasury;
        dexTreasury = _dexTreasury;
        signer = _signer;

        emit SetConfig(
            totalSupply,
            virtualTokenReserves,
            virtualCollateralReserves,
            feeBasisPoints,
            dexFeeBasisPoints,
            migrationFeeFixed,
            poolCreationFee,
            mcUpperLimit,
            mcLowerLimit,
            tokensMigrationThreshold,
            treasury,
            dexTreasury,
            signer
        );
    }

    function _checkSignatureAndStore(
        string memory _name,
        string memory _symbol,
        string memory _tokenURI,
        uint256 _nonce,
        bytes memory _signature
    ) internal {
        if (usedSignatures[keccak256(_signature)]) revert SignatureIsUsed();


        bytes32 message = keccak256(
            abi.encodePacked(
                _name,
                _symbol,
                _tokenURI,
                _nonce,
                address(this),
                block.chainid,
                msg.sender
            )
        );
        

        if (
            !SignatureChecker.isValidSignatureNow(
                signer,
                MessageHashUtils.toEthSignedMessageHash(message),
                _signature
            )
        ) revert InvalidSignature();

        usedSignatures[keccak256(_signature)] = true;
    }

    receive() external payable {}
}
