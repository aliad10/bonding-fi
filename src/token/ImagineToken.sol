// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {ERC20} from "@openzeppelin-contracts-5.1.0/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin-contracts-5.1.0/access/Ownable.sol";
import {IERC20} from "@openzeppelin-contracts-5.1.0/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin-contracts-5.1.0/utils/ReentrancyGuard.sol";
import {ERC20Burnable} from "@openzeppelin-contracts-5.1.0/token/ERC20/extensions/ERC20Burnable.sol";
import {IImagineToken} from "./IImagineToken.sol";
import {IUniswapV2Router02} from "./../utils/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "./../utils/IUniswapV2Factory.sol";

contract ImagineToken is ERC20Burnable, IImagineToken, ReentrancyGuard {
    CurveType public constant curveType = CurveType.ConstantProductV1;

    uint256 public initalTokenSupply;
    uint256 public virtualTokenReserves;
    uint256 public virtualCollateralReserves;
    uint256 public immutable virtualCollateralReservesInitial;

    uint256 public immutable feeBPS;
    uint256 public immutable dexFeeBPS;

    uint256 public immutable mcLowerLimit;
    uint256 public immutable mcUpperLimit;
    uint256 public immutable tokensMigrationThreshold;

    uint256 public immutable fixedMigrationFee;
    uint256 public immutable poolCreationFee;

    address public immutable creator;
    address public immutable pair;
    address public immutable treasury;
    address public immutable dexTreasury;
    address public immutable factory;

    bool public tradingStopped;
    bool public sendingToPairNotAllowed = true;

    string private _tokenURI;

    uint256 public constant MAX_BPS = 10_000;

    IUniswapV2Router02 public immutable uniswapV2Router;

    modifier buyChecks() {
        if (tradingStopped) revert TradingStopped();
        _;
        _checkMcLower();
        _checkMcUpperLimit();
    }

    modifier sellChecks() {
        if (tradingStopped) revert TradingStopped();
        _;
    }

    modifier onlyFactory() {
        if (msg.sender != factory) revert OnlyFactory();
        _;
    }

    constructor(
        ConstructorParams memory _params
    ) ERC20(_params.name, _params.symbol) {
        _mint(address(this), _params.totalSupply);
        _tokenURI = _params.tokenURI;

        initalTokenSupply = _params.totalSupply;
        virtualCollateralReserves = _params.virtualCollateralReserves;
        virtualCollateralReservesInitial = _params.virtualCollateralReserves;
        virtualTokenReserves = _params.virtualTokenReserves;

        creator = _params.creator;

        feeBPS = _params.feeBasisPoints;
        dexFeeBPS = _params.dexFeeBasisPoints;

        treasury = _params.treasury;
        dexTreasury = _params.dexTreasury;

        fixedMigrationFee = _params.migrationFeeFixed;
        poolCreationFee = _params.poolCreationFee;

        mcLowerLimit = _params.mcLowerLimit;
        mcUpperLimit = _params.mcUpperLimit;
        tokensMigrationThreshold = _params.tokensMigrationThreshold;

        uniswapV2Router = IUniswapV2Router02(_params.uniV2Router);
        factory = msg.sender;
        (address token0, address token1) = address(this) <
            uniswapV2Router.WETH()
            ? (address(this), uniswapV2Router.WETH())
            : (uniswapV2Router.WETH(), address(this));

        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            address(uniswapV2Router.factory()),
                            keccak256(abi.encodePacked(token0, token1)),
                            hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f" // init code hash
                        )
                    )
                )
            )
        );
    }

    // Function to set the token URI.
    function setTokenURI(string memory tokenURI_) external onlyFactory {
        _tokenURI = tokenURI_;
    }

    /**
     * @dev Buys tokenAmount of tokens for eth, refunding excess eth
     *
     * @param _tokenAmount - amount of tokens to buy
     * @param _maxCollateralAmount - maximum amount of collateral a caller is willing to spend
     */
    function buyExactOut(
        uint256 _tokenAmount,
        uint256 _maxCollateralAmount
    )
        external
        payable
        onlyFactory
        buyChecks
        returns (
            uint256 collateralToPayWithFee,
            uint256 helioFee,
            uint256 dexFee
        )
    {
        if (balanceOf(address(this)) <= _tokenAmount)
            revert InsufficientTokenReserves();

        uint256 collateralToSpend = (_tokenAmount * virtualCollateralReserves) /
            (virtualTokenReserves - _tokenAmount);

        (helioFee, dexFee) = _calculateFee(collateralToSpend);

        collateralToPayWithFee = collateralToSpend + helioFee + dexFee;

        if (collateralToPayWithFee > _maxCollateralAmount)
            revert SlippageCheckFailed();
        _transferCollateral(treasury, helioFee);
        _transferCollateral(dexTreasury, dexFee);

        virtualTokenReserves -= _tokenAmount;
        virtualCollateralReserves += collateralToSpend;

        uint256 refund;
        if (msg.value > collateralToPayWithFee) {
            // refund the user
            refund = msg.value - collateralToPayWithFee;
            _transferCollateral(msg.sender, refund);
        } else if (msg.value < collateralToPayWithFee) {
            revert NotEnoughtETHToBuyTokens();
        }

        _transfer(address(this), msg.sender, _tokenAmount);
    }

    /**
     * @dev Buys tokens specifing minimal amount of tokens a caller gets
     *
     * @param _amountOutMin - minimal amount of tokens a caller will get
     */
    function buyExactIn(
        uint256 _amountOutMin
    )
        external
        payable
        onlyFactory
        buyChecks
        returns (
            uint256 collateralToPayWithFee,
            uint256 helioFee,
            uint256 dexFee
        )
    {
        if (balanceOf(address(this)) <= _amountOutMin)
            revert InsufficientTokenReserves();

        collateralToPayWithFee = msg.value;
        (helioFee, dexFee) = _calculateFee(collateralToPayWithFee);
        uint256 collateralToSpendMinusFee = collateralToPayWithFee -
            helioFee -
            dexFee;

        _transferCollateral(treasury, helioFee);
        _transferCollateral(dexTreasury, dexFee);

        uint256 tokensOut = (collateralToSpendMinusFee * virtualTokenReserves) /
            (virtualCollateralReserves + collateralToSpendMinusFee);

        if (tokensOut < _amountOutMin) revert SlippageCheckFailed();

        virtualTokenReserves -= tokensOut;
        virtualCollateralReserves += collateralToSpendMinusFee;

        _transfer(address(this), msg.sender, tokensOut);
    }

    /**
     * @dev Sells given amount of tokens for eth
     *
     * @param _tokenAmount - amount of tokens a caller wants to sell
     * @param _amountCollateralMin - minimum amount of collateral a seller will get
     */
    function sellExactIn(
        uint256 _tokenAmount,
        uint256 _amountCollateralMin
    )
        external
        payable
        onlyFactory
        sellChecks
        returns (
            uint256 collateralToReceiveMinusFee,
            uint256 helioFee,
            uint256 dexFee
        )
    {
        uint256 collaterallToReceive = (_tokenAmount *
            virtualCollateralReserves) / (virtualTokenReserves + _tokenAmount);

        (helioFee, dexFee) = _calculateFee(collaterallToReceive);
        collateralToReceiveMinusFee = collaterallToReceive - helioFee - dexFee;
        _transferCollateral(treasury, helioFee);
        _transferCollateral(dexTreasury, dexFee);

        if (collateralToReceiveMinusFee < _amountCollateralMin)
            revert SlippageCheckFailed();

        virtualTokenReserves += _tokenAmount;
        virtualCollateralReserves -= collaterallToReceive;

        _transferCollateral(msg.sender, collateralToReceiveMinusFee);
        _transfer(msg.sender, address(this), _tokenAmount);
    }

    /**
     * @dev Sells given amount of tokens for eth
     *
     * @param _tokenAmountMax - max amount of tokens a caller wants to sell
     */
    function sellExactOut(
        uint256 _tokenAmountMax,
        uint256 _amountCollateral
    )
        external
        payable
        onlyFactory
        sellChecks
        returns (
            uint256 collateralToReceiveMinusFee,
            uint256 tokensOut,
            uint256 helioFee,
            uint256 dexFee
        )
    {
        (helioFee, dexFee) = _calculateFee(_amountCollateral);
        collateralToReceiveMinusFee = _amountCollateral - helioFee - dexFee;

        _transferCollateral(treasury, helioFee);
        _transferCollateral(dexTreasury, dexFee);

        tokensOut =
            (_amountCollateral * virtualTokenReserves) /
            (virtualCollateralReserves - _amountCollateral);

        if (tokensOut > _tokenAmountMax) revert SlippageCheckFailed();
        _transfer(msg.sender, address(this), tokensOut);

        virtualTokenReserves += tokensOut;
        virtualCollateralReserves -= _amountCollateral;

        _transferCollateral(msg.sender, collateralToReceiveMinusFee);
    }

    /**
     * @dev Calculates amountOut for a given amountIn
     *
     * @param _amountIn - amount in which will be transfered to the contract
     * @param _reserveIn - reserve in
     * @param _reserveOut - reserve out
     * @param _paymentTokenIsIn - if token in is a collateral token
     */
    function getAmountOutAndFee(
        uint256 _amountIn,
        uint256 _reserveIn,
        uint256 _reserveOut,
        bool _paymentTokenIsIn
    ) external view returns (uint256 amountOut, uint256 fee) {
        if (_paymentTokenIsIn) {
            (uint256 helioFee, uint256 dexFee) = _calculateFee(_amountIn);
            fee = helioFee + dexFee;

            amountOut = (_amountIn * _reserveOut) / (_reserveIn + _amountIn);
        } else {
            amountOut = (_amountIn * _reserveOut) / (_reserveIn + _amountIn);

            (uint256 helioFee, uint256 dexFee) = _calculateFee(amountOut);
            fee = helioFee + dexFee;
        }
    }

    /**
     * @dev Calculates amountIn for a given amountOut
     *
     * @param _amountOut - amount out which will be transfered from the contract
     * @param _reserveIn - reserve in
     * @param _reserveOut - reserve out
     * @param _paymentTokenIsOut - if token out is a payment token
     */
    function getAmountInAndFee(
        uint256 _amountOut,
        uint256 _reserveIn,
        uint256 _reserveOut,
        bool _paymentTokenIsOut
    ) external view returns (uint256 amountIn, uint256 fee) {
        if (_paymentTokenIsOut) {
            (uint256 helioFee, uint256 dexFee) = _calculateFee(_amountOut);
            fee = helioFee + dexFee;

            amountIn = (_amountOut * _reserveIn) / (_reserveOut - _amountOut);
        } else {
            amountIn = (_amountOut * _reserveIn) / (_reserveOut - _amountOut);
            (uint256 helioFee, uint256 dexFee) = _calculateFee(amountIn);

            fee = helioFee + dexFee;
        }
    }

    /**
     * @dev migrates tokens and collateral to uniswap-v2 and burns LP tokens
     */
    function migrate()
        external
        onlyFactory
        returns (
            uint256 tokensToMigrate,
            uint256 tokensToBurn,
            uint256 collateralAmount
        )
    {
        sendingToPairNotAllowed = false;

        uint256 tokensRemaining = balanceOf(address(this));
        IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
        this.approve(address(uniswapV2Router), tokensRemaining);

        tokensToMigrate = _tokensToMigrate();
        tokensToBurn = tokensRemaining - tokensToMigrate;

        (uint256 treasuryFee, uint256 dexFee) = _splitFee(fixedMigrationFee);
        _transferCollateral(treasury, treasuryFee + poolCreationFee);
        _transferCollateral(dexTreasury, dexFee);

        _burn(address(this), tokensToBurn);
        collateralAmount =
            virtualCollateralReserves -
            virtualCollateralReservesInitial -
            treasuryFee -
            dexFee -
            poolCreationFee;

        (, , uint256 liquidity) = uniswapV2Router.addLiquidityETH{
            value: collateralAmount
        }(
            address(this),
            tokensToMigrate,
            tokensToMigrate,
            collateralAmount,
            address(this),
            block.timestamp + 10
        );

        if (address(this).balance > 0) {
            _transferCollateral(treasury, address(this).balance);
        }

        IERC20(pair).transfer(address(0), liquidity);
    }

    function getMarketCap() public view returns (uint256) {
        uint256 mc = (virtualCollateralReserves * 10 ** 18 * totalSupply()) /
            virtualTokenReserves;
        return mc / 10 ** 18;
    }

    // Function to get the token URI
    function getTokenURI() external view returns (string memory) {
        return _tokenURI;
    }

    function getCurveProgressBps() external view returns (uint256) {
        uint256 progress = ((initalTokenSupply - balanceOf(address(this))) *
            MAX_BPS) / tokensMigrationThreshold;
        return progress < 100 ? 100 : (progress > MAX_BPS ? MAX_BPS : progress);
    }

    function _tokensToMigrate() internal view returns (uint256) {
        uint256 collateralDeductedFee = address(this).balance -
            fixedMigrationFee -
            poolCreationFee;
        return
            (virtualTokenReserves * collateralDeductedFee) /
            virtualCollateralReserves;
    }

    function _calculateFee(
        uint256 _amount
    ) internal view returns (uint256 treasuryFee, uint256 dexFee) {
        treasuryFee = (_amount * feeBPS) / MAX_BPS;
        dexFee = (treasuryFee * dexFeeBPS) / MAX_BPS;
        treasuryFee -= dexFee;
    }

    function _splitFee(
        uint256 _feeAmount
    ) internal view returns (uint256 treasuryFee, uint256 dexFee) {
        dexFee = (_feeAmount * dexFeeBPS) / MAX_BPS;
        treasuryFee = _feeAmount - dexFee;
    }

    function _transferCollateral(address _to, uint256 _amount) internal {
        (bool sent, ) = _to.call{value: _amount}("");
        if (!sent) revert FailedToSendETH();
    }

    function _checkMcUpperLimit() internal view {
        uint256 mc = getMarketCap();

        if (mc > mcUpperLimit) revert MarketcapThresholdReached();
    }

    function _checkMcLower() internal {
        uint256 mc = getMarketCap();

        if (mc > mcLowerLimit) {
            tradingStopped = true;
        }
    }

    function transfer(
        address _to,
        uint256 _value
    ) public override(ERC20, IERC20) returns (bool) {
        if (_to == pair && sendingToPairNotAllowed)
            revert SendingToPairIsNotAllowedBeforeMigration();
        return super.transfer(_to, _value);
    }
}
