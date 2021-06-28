// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract LandRegistry{

    enum registrationStatus {Default, Pending}

    struct landDetails{
        address landOwner;
        string state;
        string district;
        string village;
        uint surveyNumber;
        uint marketPrice;
        bool isDryLand;
        bool isForSale;
        address buyer;
        uint buyersOffer;
        uint minOffer;
        registrationStatus status;
    }

    address owner;

    mapping(address => uint[]) portfolio;

    mapping(uint => landDetails) accessLandDetails;

    mapping(string => address) villageAdmin;

    mapping(address => string) linkAadhar;

    mapping(string => uint) verifyAadhar;

    mapping(address => uint) adminHeirarchy;

    address[] requestList;
    uint index = 0;

    constructor() {
        owner = msg.sender;
        adminHeirarchy[msg.sender] = 2;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function addAadhar(string memory _aadharNumber, address _landOwner) public {
        require(adminHeirarchy[msg.sender] > 0 && verifyAadhar[_aadharNumber] == 0);
        linkAadhar[_landOwner] = _aadharNumber;
        verifyAadhar[_aadharNumber]++;
    }

    function generateLandId(string memory _state, string memory _district, string memory _village, uint _surveyNumber) public pure returns(uint) {
        return uint(keccak256(abi.encodePacked(_state, _district, _village, _surveyNumber)))% (10**10);
    }

    function addVillageAdmin(string memory _village, address _adminAddress) public onlyOwner {
        villageAdmin[_village] = _adminAddress;
        adminHeirarchy[_adminAddress]++;
    }

    function addLandDetails(address _landOwner, string memory _state, string memory _district, string memory _village, uint _surveyNumber, uint _marketPrice, bool _isDryLand, string memory _ownerAadharNumber) public {
        require(msg.sender == villageAdmin[_village] || msg.sender == owner);
        if(verifyAadhar[_ownerAadharNumber] == 0){
            linkAadhar[_landOwner] = _ownerAadharNumber;
            verifyAadhar[_ownerAadharNumber]++;
        }
        uint landId = generateLandId(_state, _district, _village, _surveyNumber);
        portfolio[_landOwner].push(landId);
        accessLandDetails[landId].landOwner = _landOwner;
        accessLandDetails[landId].state = _state;
        accessLandDetails[landId].district = _district;
        accessLandDetails[landId].village = _village;
        accessLandDetails[landId].surveyNumber = _surveyNumber;
        accessLandDetails[landId].marketPrice = _marketPrice;
        accessLandDetails[landId].isDryLand = _isDryLand;
        accessLandDetails[landId].status = registrationStatus.Default;
    }

    function checkLandInfo(uint _landId) public view returns(address, bool, uint, uint) {
        return (accessLandDetails[_landId].landOwner, accessLandDetails[_landId].isForSale, accessLandDetails[_landId].minOffer, accessLandDetails[_landId].buyersOffer);
    }

    function changeLandStatues(uint _landId, bool _isForSale) public {
        require(accessLandDetails[_landId].landOwner == msg.sender);
        accessLandDetails[_landId].isForSale = _isForSale;
    }

    function viewMyPortfolio() public view returns(uint[] memory) {
        return portfolio[msg.sender];
    }

    function viewPortfolio(address _landOwner) public view returns(uint[] memory) {
        return portfolio[_landOwner];
    }

    function makeAnOffer(uint _landId, uint _buyersOffer) public {
        require(accessLandDetails[_landId].isForSale && _buyersOffer >= accessLandDetails[_landId].marketPrice && _buyersOffer >= accessLandDetails[_landId].minOffer && _buyersOffer > accessLandDetails[_landId].buyersOffer);
        require(verifyAadhar[linkAadhar[msg.sender]] == 1);
        accessLandDetails[_landId].buyer = msg.sender;
        accessLandDetails[_landId].buyersOffer = _buyersOffer;
        accessLandDetails[_landId].status = registrationStatus.Pending;
    }

    function withdrawOffer(uint _landId) public {
        require(accessLandDetails[_landId].buyer == msg.sender);
        accessLandDetails[_landId].buyer = address(0);
        accessLandDetails[_landId].buyersOffer = 0;
        accessLandDetails[_landId].status = registrationStatus.Default;
    }

    function rejectOffer(uint _landId) public {
        require(accessLandDetails[_landId].landOwner == msg.sender);
        accessLandDetails[_landId].buyer = address(0);
        accessLandDetails[_landId].buyersOffer = 0;
        accessLandDetails[_landId].status = registrationStatus.Default;
    }

    function _findIndex(uint _landId, address _landOwner) private view returns(uint) {
        uint i;
        for(i=0; i<portfolio[_landOwner].length; i++){
            if(portfolio[_landOwner][i] == _landId){
                return i;
            }
        }
        return i;
    }

    function acceptOfferInitiateTransfer(uint _landId) public {
        require(msg.sender == accessLandDetails[_landId].landOwner);
        address _landOwner = msg.sender;
        address _buyer = accessLandDetails[_landId].buyer;
        uint portfolioIndex = _findIndex(_landId, _landOwner);
        portfolio[_buyer].push(portfolio[_landOwner][portfolioIndex]);
        portfolio[_landOwner][portfolioIndex] = portfolio[_landOwner][portfolio[_landOwner].length-1];
        portfolio[_landOwner].pop();
        accessLandDetails[_landId].landOwner = _buyer;
        accessLandDetails[_landId].isForSale = false;
        accessLandDetails[_landId].buyer = address(0);
        accessLandDetails[_landId].buyersOffer = 0;
        accessLandDetails[_landId].minOffer = 0;
        accessLandDetails[_landId].status = registrationStatus.Default;
    }

    function setMinOffer(uint _landId, uint _minOffer) public {
        require(msg.sender == accessLandDetails[_landId].landOwner);
        accessLandDetails[_landId].minOffer = _minOffer;
    }

    function editMarketValue(uint _landId, uint _marketPrice) public{
        require(msg.sender == villageAdmin[accessLandDetails[_landId].village]);
        accessLandDetails[_landId].marketPrice = _marketPrice;
    }

    function _stringconcat(string memory _string1, string memory _string2) private pure returns (string memory) {
        return(string(abi.encodePacked(_string1, _string2)));
    }

    function _sameStrings(string memory _string1, string memory _string2) private pure returns (bool) {
        if(keccak256(abi.encodePacked(_string1)) == keccak256(abi.encodePacked(_string2))) {
            return true;
        }
        return false;
    }

    function requestAadharVerification() public {
        require(_sameStrings(linkAadhar[msg.sender], ""));
        requestList.push(msg.sender);
    }

    function accessVerificationList(string memory _aadharNumber) public {
        require(adminHeirarchy[msg.sender] > 0 && requestList.length > index && verifyAadhar[_aadharNumber] == 0);
        addAadhar(_aadharNumber, requestList[index]);
        index++;
    }
}