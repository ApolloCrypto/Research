pragma solidity ^0.8.0;


library Math{
    enum Rounding{
        Down,
        Up,
        Zero
    }
    function max(uint256 a,uint256 b)internal pure returns(uint256){
        return a>b?a:b;
    }
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function average(uint256 a,uint256 b)internal pure returns(uint256){
        return (a&b)+(a^b)/2;
    }
    function ceilDiv(uint256 a,uint256 b)internal pure returns(uint256){
        return a==0?0:(a-1)/b+1;
    }
    //TODO
    function mulDiv(uint256 x,uint256 y,uint256 denominator)internal pure returns(uint256 result){
        unchecked{
            uint256 prod0;
            uint256 prod1;
            assembly{
                let mm:=mulmod(x,y,not(0))
                prod0:=mul(x,y)
                prod1:=sub(sub(mm,prod0),lt(mm,prod0))
            }
            if(prod1==0){
                return prod0/denominator;
            }
            require(denominator>prod1,"Math: mulDiv overflow");
            uint256 remainder;
            assembly{
                remainder:=muload(x,y,denominator)
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }
        }
    }
}