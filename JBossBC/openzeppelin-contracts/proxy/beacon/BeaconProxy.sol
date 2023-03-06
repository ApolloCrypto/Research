pragma solidity ^0.8.0;
import "../ERC1967/ERC1967Upgrade.sol";
import "../proxy.sol";
contract BeaconProxy is Proxy,ERC1967Upgrade{
    constructor(address beacon,bytes memory data)payable{
        _upgradeBeaconToAndCall(beacon,data,false);
    }
    function _beacon()internal view virtual returns(address){
        return _getBeacon();
    }
    function _implementation()internal view virtual override returns(address){
        return IBeacon(_getBeacon()).implementation();
    }

    function _setBeacon(address beacon,bytes memory data)internal virtual{
        _upgradeBeaconToAndCall(beacon,data,false);
    }
}