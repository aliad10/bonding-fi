// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IERC20} from "@openzeppelin-contracts-5.1.0/token/ERC20/IERC20.sol";

interface IImagineToken is IERC20 {
    enum CurveType {
        ConstantProductV1
    }

    struct ConstructorParams {
        string name;
        string symbol;
        string tokenURI;
        address creator;
        uint256 totalSupply;
        uint256 virtualTokenReserves;
        uint256 virtualCollateralReserves;
        uint256 feeBasisPoints;
        uint256 dexFeeBasisPoints;
        uint256 migrationFeeFixed;
        uint256 poolCreationFee;
        uint256 mcLowerLimit;
        uint256 mcUpperLimit;
        uint256 tokensMigrationThreshold;
        address treasury;
        address uniV2Router;
        address dexTreasury;
    }

    error NotEnoughETHReserves();
    error InsufficientTokenReserves();
    error FailedToSendETH();
    error NotEnoughtETHToBuyTokens();
    error SlippageCheckFailed();
    error MarketcapThresholdReached();
    error SendingToPairIsNotAllowedBeforeMigration();
    error TradingStopped();
    error OnlyFactory();

    function setTokenURI(string memory tokenURI_) external;

    function buyExactOut(
        uint256 _tokenAmount,
        uint256 _maxCollateralAmount
    )
        external
        payable
        returns (
            uint256 collateralToPayWithFee,
            uint256 helioFee,
            uint256 dexFee
        );

    function buyExactIn(
        uint256 _amountOutMin
    )
        external
        payable
        returns (
            uint256 collateralToPayWithFee,
            uint256 helioFee,
            uint256 dexFee
        );

    function sellExactIn(
        uint256 _tokenAmount,
        uint256 _amountOutMin
    )
        external
        payable
        returns (
            uint256 collateralToReceiveMinusFee,
            uint256 helioFee,
            uint256 dexFee
        );

    function sellExactOut(
        uint256 _tokenAmountMax,
        uint256 _amountCollateral
    )
        external
        payable
        returns (
            uint256 collateralToReceiveMinusFee,
            uint256 tokensOut,
            uint256 helioFee,
            uint256 dexFee
        );

    function getAmountOutAndFee(
        uint256 _amountIn,
        uint256 _reserveIn,
        uint256 _reserveOut,
        bool _paymentTokenIsIn
    ) external view returns (uint256 amountOut, uint256 fee);

    function getAmountInAndFee(
        uint256 _amountOut,
        uint256 _reserveIn,
        uint256 _reserveOut,
        bool _paymentTokenIsOut
    ) external view returns (uint256 amountIn, uint256 fee);

    function migrate()
        external
        returns (
            uint256 tokensToMigrate,
            uint256 tokensToBurn,
            uint256 collateralAmount
        );

    function getCurveProgressBps() external view returns (uint256);

    function getMarketCap() external view returns (uint256);

    function getTokenURI() external view returns (string memory);
}
