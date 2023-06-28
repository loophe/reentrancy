// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "../src/IAsset.sol";
import "../src/interface.sol";

interface ISTURDY {
    function depositCollateralFrom(
        address _asset,
        uint256 _amount,
        address _user
    ) external payable;

    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function setUserUseReserveAsCollateral(
        address asset,
        bool useAsCollateral
    ) external;
}

interface ISTURDY_ORACLE {
    function getAssetPrice (address asset) external returns (uint256);
}

interface IVAULT {
    function joinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest memory request
    ) external payable;
    
    function exitPool(
        bytes32 poolId,
        address sender,
        address payable recipient,
        ExitPoolRequest memory request
    ) external;
}

struct ExitPoolRequest {
    IAsset[] assets;
    uint256[] minAmountsOut;
    bytes userData;
    bool toInternalBalance;
}

struct JoinPoolRequest {
    IAsset[] assets;
    uint256[] maxAmountsIn;
    bytes userData;
    bool fromInternalBalance;
}

interface IB is IERC20{
    function getPoolId () external returns (bytes32);
}


contract Re is Test{

    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public wstETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
    address public B_stETH_STABLE = 0x32296969Ef14EB0c6d29669C550D4a0449130230;
    address public csteCRV = 0x901247D08BEbFD449526Da92941B35D756873Bcd;
    address public steCRV = 0x06325440D014e39736583c165C2963BA99fAf14E;

    address public VAULT = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address public STURDY = 0x6AE5Fd07c0Bb2264B1F60b33F65920A2b912151C;
    address public STURDY2 = 0xa36BE47700C079BD94adC09f35B0FA93A55297bc;
    address public STURDY3 = 0x9f72DC67ceC672bB99e3d02CbEA0a21536a2b657;
    address public STURDY_ORACLE = 0xe5d78eB340627B8D5bcFf63590Ebec1EF9118C89;

    IERC20 weth = IERC20(WETH);
    IERC20 wsteth = IERC20(wstETH);
    IERC20 stecrv = IERC20(steCRV);
    IB b_steth = IB(B_stETH_STABLE);
    IERC20 cstecrv = IERC20(csteCRV);

    ISTURDY sturdy = ISTURDY(STURDY);
    ISTURDY sturdy2 = ISTURDY(STURDY2);
    ISTURDY sturdy3 = ISTURDY(STURDY3);

    ISTURDY_ORACLE oracle = ISTURDY_ORACLE(STURDY_ORACLE);
    IVAULT vault = IVAULT(VAULT);

    function testTrade2 () public {
        uint256 amount = 109517_402513296695120654;
        uint256 _amount =    49_608350311309546695;
        uint256 amountC = 1000e18;
        uint256 amountWETH = 57000e18;
        uint256 amountwstETH = 50000e18;
        deal(WETH,address(this),amountWETH);
        deal(wstETH,address(this),amountwstETH);
        deal(steCRV,address(this),amountC);
        deal(B_stETH_STABLE,address(this),amount);
        bytes32 poolId = b_steth.getPoolId();
        {   
            weth.approve(VAULT, uint256(2**256-1));
            wsteth.approve(VAULT, uint256(2**256-1));
            IAsset[] memory assets = new IAsset[](2);
            assets[0] = IAsset(wstETH);//wstWETH
            assets[1] = IAsset(WETH);//WETH
            // console.logAddress[2](assets);
            uint256[] memory maxAmountsIn = new uint256[](2);
            maxAmountsIn[0] = amountwstETH;
            maxAmountsIn[1] = amountWETH;
            JoinPoolRequest memory request = JoinPoolRequest(
                assets,
                maxAmountsIn,
                hex"0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000a968163f0a57b400000000000000000000000000000000000000000000000000c11f9e7b10e91a00000",
                false
            );
            vault.joinPool(poolId, address(this), address(this), request);
        }
        // b_steth.approve(STURDY, _amount);
        // sturdy.depositCollateralFrom(B_stETH_STABLE, _amount, address(this));
        // stecrv.approve(STURDY2, amountC);
        // sturdy2.depositCollateralFrom(steCRV, 1, address(this));
        // sturdy3.borrow(WETH, 109138370684881002730, 2, 0, address(this));
        uint256 price = oracle.getAssetPrice(B_stETH_STABLE);
        console.log("Price before :",price);

        
        // console.logBytes32(poolId);
        IAsset[] memory assets = new IAsset[](2);
        assets[0] = IAsset(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0);//wstWETH
        assets[1] = IAsset(0x0000000000000000000000000000000000000000);//ETH
        // console.logAddress[2](assets);
        uint256[] memory minAmountOuts = new uint256[](2);
        minAmountOuts[0] = 0;
        minAmountOuts[1] = 0;
        ExitPoolRequest memory request = ExitPoolRequest(
            assets,
            minAmountOuts,
            hex"000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000172e42d1b6013337be47",
            false
        );
        vault.exitPool(poolId, address(this), payable(address(this)), request);

    }

    receive() external payable {
        // sturdy3.setUserUseReserveAsCollateral(csteCRV, false);
        uint256 price = oracle.getAssetPrice(B_stETH_STABLE);
        console.log("Price during exit process :",price);
    }
}