
pragma solidity ^0.8.0;
import "../../interfaces/draft-IERC1822.sol";
import "../ERC1967/ERC1967Upgrade.sol";
abstract contract UUPSUpgradeable is IERC1822Proxiable,ERC1967Upgrade{
    address private immutable __self =address(this);
    modifier onlyProxy(){
        require(address(this)!=__self,"Function must be called through delegatecall");
        require(_getImplementation()== __self,"Function must be called through active proxy");
        _;
    }
    modifier notDelegated(){
        require(address(this)==__self,"UUPSUpgradeable: must not be called through delegatecall");
        _;
    }
    function proxiableUUID()external view virtual override notDelegated returns (bytes32){
        return _IMPLEMENTATION_SLOT;
    }
    function upgradeTo(address  newImplementation )public virtual onlyProxy{
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation,new bytes(0),false);
    }
    function upgradeToAndCall(address newImplementation, bytes memory data) public payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }
    function _authorizeUpgrade(address newImplementation) internal virtual;

}