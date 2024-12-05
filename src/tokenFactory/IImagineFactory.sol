// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

interface IImagineFactory {
    error InvalidSignature();
    error SignatureIsUsed();
    error FailedToSendETH();
    error NotReadyForMigration();

    error TotalSupplyZeroValue();
    error VirtualTokenReservesZeroValue();
    error VirtualCollateralReservesZeroValue();
    error McUpperLimitZeroValue();
    error McLowerLimitZeroValue();
    error TokensMigrationThresholdZeroValue();
    error TreasuryZeroValue();
    error DexTreasuryZeroValue();
    error SignerZeroValue();
    error FeeBPSCheckFailed();
    error McLowerLimitGreaterThanUpperLimit();

    event SetConfig(
        uint256 totalSupply,
        uint256 virtualTokenReserves,
        uint256 virtualCollateralReserves,
        uint256 feeBasisPoints,
        uint256 dexFeeBasisPoints,
        uint256 migrationFeeFixed,
        uint256 poolCreationFee,
        uint256 mcUpperLimit,
        uint256 mcLowerLimit,
        uint256 tokensMigrationThreshold,
        address treasury,
        address dexTreasury,
        address signer
    );

    event NewImagineToken(address addr, address creator, bytes signature);

    event NewImagineTokenAndBuy(
        address addr,
        address creator,
        bytes signature,
        uint256 tokenAmount,
        uint256 collateralAmount,
        uint256 fee,
        uint256 dexFee,
        uint256 curveProgressBps
    );

    event MarketcapReached(address token);

    event Migrated(
        address token,
        uint256 tokensToMigrate,
        uint256 tokensToBurn,
        uint256 collateralToMigrate,
        uint256 migrationFee,
        address pair
    );

    event BuyExactOut(
        address indexed buyer,
        address indexed token,
        uint256 tokenAmount,
        uint256 curvePositionAfterTrade,
        uint256 collateralAmount,
        uint256 refund,
        uint256 fee,
        uint256 dexFee,
        uint256 curveProgressBps
    );

    event BuyExactIn(
        address indexed buyer,
        address indexed token,
        uint256 tokenAmount,
        uint256 curvePositionAfterTrade,
        uint256 collateralAmount,
        uint256 fee,
        uint256 dexFee,
        uint256 curveProgressBps
    );

    event SellExactIn(
        address indexed seller,
        address indexed token,
        uint256 tokenAmount,
        uint256 curvePositionAfterTrade,
        uint256 collateralAmount,
        uint256 fee,
        uint256 dexFee,
        uint256 curveProgressBps
    );

    event SellExactOut(
        address indexed seller,
        address indexed token,
        uint256 tokenAmount,
        uint256 curvePositionAfterTrade,
        uint256 collateralAmount,
        uint256 fee,
        uint256 dexFee,
        uint256 curveProgressBps
    );

    function buyExactOut(
        address _token,
        uint256 _tokenAmount,
        uint256 _maxCollateralAmount
    ) external payable;

    function buyExactIn(address _token, uint256 _amountOutMin) external payable;

    function sellExactIn(
        address _token,
        uint256 _tokenAmount,
        uint256 _amountCollateralMin
    ) external;

    function sellExactOut(
        address _token,
        uint256 _tokenAmountMax,
        uint256 _amountCollateral
    ) external;

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
    ) external;

    function createImagineToken(
        string memory _name,
        string memory _symbol,
        uint256 _nonce,
        bytes memory _signature
    ) external returns (address);

    function createImagineTokenAndBuy(
        string memory _name,
        string memory _symbol,
        uint256 _nonce,
        uint256 _tokenAmountMin,
        bytes memory _signature
    ) external payable returns (address);
}
