import "../utils/Address.sol";
abstract contract Initializable{
    uint8 private _initialized;
    bool private _initializing;
    event Initialized(uint8 version);
    modifier initializer(){
        bool isTopLevelCall =!_initializing;
        require((isTopLevelCall&&_initialized<1)||!Address.isContract(address(this))&&_initialized==1,"Initializable: contract is already initialized");
     _initialized=1;
     if(isTopLevelCall){
        _initializing=true;
     }
   _;
   if(isTopLevelCall){
    _initializing=false;
    emit Initializable(1);
   }
    }
 modifier reintializer(uint8 version){
    require(!_initializing&&_initialized<version,"Initializable: contract is already initialized");
    _initialized=version;
    _initializing=true;
    _;
    _initializing=false;
    emit Initializable(version);
 }
 modifier onlyInitializing(){
    require(_initializing,"Initializable: contract is not initializing");
    _;
 }
 function _disableInitializers()internal virtual{
    require(!_initializing,"Initializable: contract is initializing");
    if(_initialized!=type(uint8).max){
        _initialized=type(uint8).max;
        emit Initialized(type(uint8).max);
    }
 }
  function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }
     function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}