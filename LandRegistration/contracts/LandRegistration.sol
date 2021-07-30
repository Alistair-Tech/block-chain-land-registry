// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract LandRegistration {
    
    struct landDetails {
        address landOwner;
        string state;
        string district;
        string village;
        string surveyNumber;
        string subDivisionNumber;
        int latitudeDegree;
        int latitudeMinute;
        int latitudeSecond;
        int longitudeDegree;
        int longitudeMinute;
        int longitudeSecond;
        uint radius;
        uint areaInCents;
        uint marketPrice;
        bool isDryLand;
        bool isForSale;
        uint areaForSale;
        int latitudeDegreeOfAreaForSale;
        int latitudeMinuteOfAreaForSale;
        int latitudeSecondOfAreaForSale;
        int longitudeDegreeOfAreaForSale;
        int longitudeMinuteOfAreaForSale;
        int longitudeSecondOfAreaForSale;
        uint marketPriceOfAreaForSale;
        uint radiusOfAreaForSale;
        bool verifiedSaleDetails;
        uint minOffer;
        bool hasAnOffer;
        address buyersAddress;
        uint buyersOffer;
        int latitudeDegreeAfterSale;
        int latitudeMinuteAfterSale;
        int latitudeSecondAfterSale;
        int longitudeDegreeAfterSale;
        int longitudeMinuteAfterSale;
        int longitudeSecondAfterSale;
        uint marketPriceAfterSale;
        uint radiusAfterSale;
    }

    struct personalInfo {
        string firstName;
        string lastName;
        string addressInfo;
        string aadharNumber;
        string panNumber;
        string phoneNumber;
    }

    address owner;

    mapping(address => uint[]) portfolio;

    mapping(uint => landDetails) accessLandDetails;

    mapping(string => address) villageAdmin;

    mapping(address => uint) adminHierarchy;

    mapping(address => personalInfo) personalDetails;

    mapping(address => uint) linkAadhar;

    address[] requestList;

    uint[] requestOfSaleDetails;

    constructor() {
        owner = msg.sender;
        adminHierarchy[owner] = 2;
    }

    function addVillageAdmin(address _adminAddress, string memory _village) public {
        require(msg.sender == owner);
        villageAdmin[_village] = _adminAddress;
        adminHierarchy[_adminAddress]++;
    }

    function generateLandId(string memory _state, string memory _district, string memory _village, string memory _surveyNumber, string memory _subDivisionNumber) public pure returns(uint) {
        return uint(keccak256(abi.encodePacked(_state, _district, _village, _surveyNumber, _subDivisionNumber))) % (10**25);

    }

    function addLandDetails(address _landOwner, string memory _state, string memory _district, string memory _village, string memory _surveyNumber, string memory _subDivisionNumber, uint _ownerAadharNumber) public {
        require(adminHierarchy[msg.sender] > 0);
        if(linkAadhar[_landOwner] == 0){
            linkAadhar[_landOwner] = _ownerAadharNumber;
        }
        uint landId = generateLandId(_state, _district, _village, _surveyNumber, _subDivisionNumber);
        portfolio[_landOwner].push(landId);
        accessLandDetails[landId].landOwner = _landOwner;
        accessLandDetails[landId].state = _state;
        accessLandDetails[landId].district = _district;
        accessLandDetails[landId].village = _village;
        accessLandDetails[landId].surveyNumber = _surveyNumber;
        accessLandDetails[landId].subDivisionNumber = _subDivisionNumber;
    }

    function addLandCoordinates(uint _landId, int _latitudeDegree, int _latitudeMinute, int _latitudeSecond, int _longitudeDegree, int _longitudeMinute, int _longitudeSecond, uint _radius, uint _areaInCents, uint _marketPrice, bool _isDryLand) public {
        require(adminHierarchy[msg.sender] > 0);
        accessLandDetails[_landId].latitudeDegree = _latitudeDegree;
        accessLandDetails[_landId].latitudeMinute = _latitudeMinute;
        accessLandDetails[_landId].latitudeSecond = _latitudeSecond;
        accessLandDetails[_landId].longitudeDegree = _longitudeDegree;
        accessLandDetails[_landId].longitudeMinute = _longitudeMinute;
        accessLandDetails[_landId].longitudeSecond = _longitudeSecond;
        accessLandDetails[_landId].radius = _radius;
        accessLandDetails[_landId].areaInCents = _areaInCents;
        accessLandDetails[_landId].marketPrice = _marketPrice;
        accessLandDetails[_landId].isDryLand = _isDryLand;
    }

    function requestLinkAadhar() public {
        require(linkAadhar[msg.sender] == 0);
        requestList.push(msg.sender);
    }

    function addPersonalInfo(string memory _firstName, string memory _lastName, string memory _addressInfo, string memory _aadharNumber, string memory _panNumber, string memory _phoneNumber) public {
        personalDetails[msg.sender].firstName = _firstName;
        personalDetails[msg.sender].lastName = _lastName;
        personalDetails[msg.sender].addressInfo = _addressInfo;
        personalDetails[msg.sender].aadharNumber = _aadharNumber;
        personalDetails[msg.sender].panNumber = _panNumber;
        personalDetails[msg.sender].phoneNumber = _phoneNumber;
    }

    function viewDetailsInRequestList() public view returns(string memory, string memory, string memory, string memory, string memory, string memory) {
        return (personalDetails[requestList[0]].firstName, personalDetails[requestList[0]].lastName, personalDetails[requestList[0]].addressInfo, personalDetails[requestList[0]].aadharNumber, personalDetails[requestList[0]].panNumber, personalDetails[requestList[0]].phoneNumber);
    }

    function verifyAadhar(uint _OwnerAadharNumber) public {
        require(requestList.length > 0 && adminHierarchy[msg.sender] > 0);
        linkAadhar[requestList[0]] = _OwnerAadharNumber;
        _popRequestList();
    }

    function editMarketPrice(uint _landId, uint _marketPrice) public {
        require(adminHierarchy[msg.sender] > 0);
        accessLandDetails[_landId].marketPrice = _marketPrice;
    }

    function viewMyPortfolio() public view returns(uint[] memory) {
        return portfolio[msg.sender];
    }

    function viewPortfolio(address _ownerAddress) public view returns(uint[] memory) {
        return portfolio[_ownerAddress];
    }

    // function elaboratedLandInfo(uint _landId) public view returns(address, string memory, string memory, string memory, string memory, string memory, int, int, int, int, int, int, uint, uint, uint, bool, bool, uint, uint, bool, uint) {
    //     return (accessLandDetails[_landId].landOwner, accessLandDetails[_landId].state, accessLandDetails[_landId].district, accessLandDetails[_landId].village, accessLandDetails[_landId].surveyNumber, accessLandDetails[_landId].subDivisionNumber, accessLandDetails[_landId].latitudeDegree, accessLandDetails[_landId].latitudeMinute, accessLandDetails[_landId].latitudeSecond, accessLandDetails[_landId].longitudeDegree, accessLandDetails[_landId].longitudeMinute, accessLandDetails[_landId].longitudeSecond, accessLandDetails[_landId].radius, accessLandDetails[_landId].areaInCents, accessLandDetails[_landId].marketPrice, accessLandDetails[_landId].isDryLand, accessLandDetails[_landId].isForSale, accessLandDetails[_landId].areaForSale, accessLandDetails[_landId].minOffer, accessLandDetails[_landId].hasAnOffer, accessLandDetails[_landId].buyersOffer);
    // }

    function ecomomicLandInfo(uint _landId) public view returns(uint, uint, bool, uint, uint, bool, uint) {
        return (accessLandDetails[_landId].marketPrice, accessLandDetails[_landId].areaInCents, accessLandDetails[_landId].isForSale, accessLandDetails[_landId].areaForSale, accessLandDetails[_landId].minOffer, accessLandDetails[_landId].isDryLand, accessLandDetails[_landId].buyersOffer);
    }

    function landForSale(uint _landId, uint _areaForSale, int _latitudeDegreeOfAreaForSale, int _latitudeMinuteOfAreaForSale, int _latitudeSecondOfAreaForSale, int _longitudeDegreeOfAreaForSale, int _longitudeMinuteOfAreaForSale, int _longitudeSecondOfAreaForSale, uint _marketPriceOfAreaForSale, uint _radiusOfAreaForSale, uint _minOffer) public {
        require(msg.sender == accessLandDetails[_landId].landOwner);
        accessLandDetails[_landId].isForSale = true;
        accessLandDetails[_landId].areaForSale = _areaForSale;
        accessLandDetails[_landId].latitudeDegreeOfAreaForSale = _latitudeDegreeOfAreaForSale;
        accessLandDetails[_landId].latitudeMinuteOfAreaForSale = _latitudeMinuteOfAreaForSale;
        accessLandDetails[_landId].latitudeSecondOfAreaForSale = _latitudeSecondOfAreaForSale;
        accessLandDetails[_landId].longitudeDegreeOfAreaForSale = _longitudeDegreeOfAreaForSale;
        accessLandDetails[_landId].longitudeMinuteOfAreaForSale = _longitudeMinuteOfAreaForSale;
        accessLandDetails[_landId].longitudeSecondOfAreaForSale = _longitudeSecondOfAreaForSale;
        accessLandDetails[_landId].marketPriceOfAreaForSale = _marketPriceOfAreaForSale;
        accessLandDetails[_landId].radiusOfAreaForSale = _radiusOfAreaForSale;
        accessLandDetails[_landId].minOffer = _minOffer;

        _requestVerificationOfSaleDetails(_landId);
    }

    function modifyMinOffer(uint _landId, uint _minOffer) public {
        require(msg.sender == accessLandDetails[_landId].landOwner);
        accessLandDetails[_landId].minOffer = _minOffer;
    }

    function removeLandForSale(uint _landId) public {
        require(msg.sender == accessLandDetails[_landId].landOwner);
        _initializeLandDetails(_landId);
    }

    function _requestVerificationOfSaleDetails(uint _landId) private {
        requestOfSaleDetails.push(_landId);
    }

    function viewVerificationOfSaleDetails() public returns(int, int, int, int, int, int, uint, uint) {
        require(adminHierarchy[msg.sender] > 0);
        while(requestOfSaleDetails.length > 0 && accessLandDetails[requestOfSaleDetails[0]].isForSale == false){
            _popRequestOfSaleDetails();
        }
        if(requestOfSaleDetails.length > 0){
            return(accessLandDetails[requestOfSaleDetails[0]].latitudeDegreeOfAreaForSale, accessLandDetails[requestOfSaleDetails[0]].latitudeMinuteOfAreaForSale, accessLandDetails[requestOfSaleDetails[0]].latitudeSecondOfAreaForSale, accessLandDetails[requestOfSaleDetails[0]].longitudeDegreeOfAreaForSale, accessLandDetails[requestOfSaleDetails[0]].longitudeMinuteOfAreaForSale, accessLandDetails[requestOfSaleDetails[0]].longitudeSecondOfAreaForSale, accessLandDetails[requestOfSaleDetails[0]].radiusOfAreaForSale, accessLandDetails[requestOfSaleDetails[0]].marketPriceOfAreaForSale);
        }
        
        return (0,0,0,0,0,0,0,0);
    }

    function approveSaleDetails() public {
        require(adminHierarchy[msg.sender] > 0);
        accessLandDetails[requestOfSaleDetails[0]].verifiedSaleDetails = true;
        _popRequestOfSaleDetails();
    }

    function rejectSaleDetails() public {
        require(adminHierarchy[msg.sender] > 0);
        _popRequestOfSaleDetails();
    }

    function approveSaleDetails(int _latitudeDegreeAfterSale, int _latitudeMinuteAfterSale, int _latitudeSecondAfterSale, int _longitudeDegreeAfterSale, int _longitudeMinuteAfterSale, int _longitudeSecondAfterSale, uint _marketPriceAfterSale, uint _radiusAfterSale) public {
        require(adminHierarchy[msg.sender] > 0);
        accessLandDetails[requestOfSaleDetails[0]].latitudeDegreeAfterSale = _latitudeDegreeAfterSale;
        accessLandDetails[requestOfSaleDetails[0]].latitudeMinuteAfterSale = _latitudeMinuteAfterSale;
        accessLandDetails[requestOfSaleDetails[0]].latitudeSecondAfterSale = _latitudeSecondAfterSale;
        accessLandDetails[requestOfSaleDetails[0]].longitudeDegreeAfterSale = _longitudeDegreeAfterSale;
        accessLandDetails[requestOfSaleDetails[0]].longitudeMinuteAfterSale = _longitudeMinuteAfterSale;
        accessLandDetails[requestOfSaleDetails[0]].longitudeSecondAfterSale = _longitudeSecondAfterSale;
        accessLandDetails[requestOfSaleDetails[0]].marketPriceAfterSale = _marketPriceAfterSale;
        accessLandDetails[requestOfSaleDetails[0]].radiusAfterSale = _radiusAfterSale;
    }

    function makeAnOffer(uint _landId, uint _buyersOffer) public {
        require(accessLandDetails[_landId].isForSale && accessLandDetails[_landId].landOwner != msg.sender && accessLandDetails[_landId].verifiedSaleDetails && accessLandDetails[_landId].minOffer < _buyersOffer && accessLandDetails[_landId].buyersOffer < _buyersOffer);
        accessLandDetails[_landId].buyersAddress = msg.sender;
        accessLandDetails[_landId].buyersOffer = _buyersOffer;
        accessLandDetails[_landId].hasAnOffer = true;
    }

    function withdrawOffer(uint _landId) public {
        require(accessLandDetails[_landId].buyersAddress == msg.sender);
        accessLandDetails[_landId].buyersAddress = address(0);
        accessLandDetails[_landId].buyersOffer = 0;
        accessLandDetails[_landId].hasAnOffer = false;
    }

    function viewOffer(uint _landId) public view returns(uint) {
        return accessLandDetails[_landId].buyersOffer;
    }

    function acceptOffer(uint _landId) public {
        require(msg.sender == accessLandDetails[_landId].landOwner);
        if(accessLandDetails[_landId].areaForSale == accessLandDetails[_landId].areaInCents){
            _completeTransfer(_landId);
        }
        else {
            _partialTransfer(_landId);
        }
    }

    function rejectOffer(uint _landId) public {
        require(accessLandDetails[_landId].landOwner == msg.sender);
        accessLandDetails[_landId].buyersAddress = address(0);
        accessLandDetails[_landId].buyersOffer = 0;
        accessLandDetails[_landId].hasAnOffer = false;
    }

    function _completeTransfer(uint _landId) private {
        _removeAssetFromPortfolio(_landId, accessLandDetails[_landId].landOwner);
        accessLandDetails[_landId].landOwner = accessLandDetails[_landId].buyersAddress;
        _initializeLandDetails(_landId);
        portfolio[accessLandDetails[_landId].landOwner].push(_landId);
    }

    function _partialTransfer(uint _landId) private {
        string memory _subDivisionNumber1 = _stringconcat(accessLandDetails[_landId].subDivisionNumber, "/1");
        string memory _subDivisionNumber2 = _stringconcat(accessLandDetails[_landId].subDivisionNumber, "/2");
        
        uint _landId1 = generateLandId(accessLandDetails[_landId].state, accessLandDetails[_landId].district, accessLandDetails[_landId].village, accessLandDetails[_landId].surveyNumber, _subDivisionNumber1);
        uint _landId2 = generateLandId(accessLandDetails[_landId].state, accessLandDetails[_landId].district, accessLandDetails[_landId].village, accessLandDetails[_landId].surveyNumber, _subDivisionNumber2);
        
        _removeAssetFromPortfolio(_landId, accessLandDetails[_landId].landOwner);
        
        _initializeLandDetails(_landId1);
        _initializeLandDetails(_landId2);
        accessLandDetails[_landId1].landOwner = accessLandDetails[_landId].landOwner;
        accessLandDetails[_landId1].state = accessLandDetails[_landId].state;
        accessLandDetails[_landId1].district = accessLandDetails[_landId].district;
        accessLandDetails[_landId1].village = accessLandDetails[_landId].village;
        accessLandDetails[_landId1].surveyNumber = accessLandDetails[_landId].surveyNumber;
        accessLandDetails[_landId1].subDivisionNumber = _subDivisionNumber1;
        accessLandDetails[_landId1].latitudeDegree = accessLandDetails[_landId].latitudeDegreeAfterSale;
        accessLandDetails[_landId1].latitudeMinute = accessLandDetails[_landId].latitudeMinuteAfterSale;
        accessLandDetails[_landId1].latitudeSecond = accessLandDetails[_landId].latitudeSecondAfterSale;
        accessLandDetails[_landId1].longitudeDegree = accessLandDetails[_landId].longitudeDegreeAfterSale;
        accessLandDetails[_landId1].longitudeMinute = accessLandDetails[_landId].longitudeMinuteAfterSale;
        accessLandDetails[_landId1].longitudeSecond = accessLandDetails[_landId].longitudeSecondAfterSale;
        accessLandDetails[_landId1].radius = accessLandDetails[_landId].radiusAfterSale;
        accessLandDetails[_landId1].areaInCents = accessLandDetails[_landId].areaInCents - accessLandDetails[_landId].areaForSale;
        accessLandDetails[_landId1].marketPrice = accessLandDetails[_landId].marketPriceAfterSale;
        accessLandDetails[_landId1].isDryLand = accessLandDetails[_landId].isDryLand;
        
        accessLandDetails[_landId2].landOwner = accessLandDetails[_landId].buyersAddress;
        accessLandDetails[_landId2].state = accessLandDetails[_landId].state;
        accessLandDetails[_landId2].district = accessLandDetails[_landId].district;
        accessLandDetails[_landId2].village = accessLandDetails[_landId].village;
        accessLandDetails[_landId2].surveyNumber = accessLandDetails[_landId].surveyNumber;
        accessLandDetails[_landId2].subDivisionNumber = _subDivisionNumber2;
        accessLandDetails[_landId2].latitudeDegree = accessLandDetails[_landId].latitudeDegreeOfAreaForSale;
        accessLandDetails[_landId2].latitudeMinute = accessLandDetails[_landId].latitudeMinuteOfAreaForSale;
        accessLandDetails[_landId2].latitudeSecond = accessLandDetails[_landId].latitudeSecondOfAreaForSale;
        accessLandDetails[_landId2].longitudeDegree = accessLandDetails[_landId].longitudeDegreeOfAreaForSale;
        accessLandDetails[_landId2].longitudeMinute = accessLandDetails[_landId].longitudeMinuteOfAreaForSale;
        accessLandDetails[_landId2].longitudeSecond = accessLandDetails[_landId].longitudeSecondOfAreaForSale;
        accessLandDetails[_landId2].radius = accessLandDetails[_landId].radiusOfAreaForSale;
        accessLandDetails[_landId2].areaInCents = accessLandDetails[_landId].areaForSale;
        accessLandDetails[_landId2].marketPrice = accessLandDetails[_landId].marketPriceOfAreaForSale;
        accessLandDetails[_landId2].isDryLand = accessLandDetails[_landId].isDryLand;

        portfolio[accessLandDetails[_landId1].landOwner].push(_landId1);
        portfolio[accessLandDetails[_landId2].landOwner].push(_landId2);

        _deleteLandDetails(_landId);
    }

    function _initializeLandDetails(uint _landId) private {
        accessLandDetails[_landId].isForSale = false;
        accessLandDetails[_landId].areaForSale = 0;
        accessLandDetails[_landId].latitudeDegreeOfAreaForSale = 0;
        accessLandDetails[_landId].latitudeMinuteOfAreaForSale = 0;
        accessLandDetails[_landId].latitudeSecondOfAreaForSale = 0;
        accessLandDetails[_landId].longitudeDegreeOfAreaForSale = 0;
        accessLandDetails[_landId].longitudeMinuteOfAreaForSale = 0;
        accessLandDetails[_landId].longitudeSecondOfAreaForSale = 0;
        accessLandDetails[_landId].marketPriceOfAreaForSale = 0;
        accessLandDetails[_landId].radiusOfAreaForSale = 0;
        accessLandDetails[_landId].minOffer = 0;
        accessLandDetails[_landId].verifiedSaleDetails = false;
        accessLandDetails[_landId].hasAnOffer = false;
        accessLandDetails[_landId].buyersAddress = address(0);
        accessLandDetails[_landId].buyersOffer = 0;
        accessLandDetails[_landId].latitudeDegreeAfterSale = 0;
        accessLandDetails[_landId].latitudeMinuteAfterSale = 0;
        accessLandDetails[_landId].latitudeSecondAfterSale = 0;
        accessLandDetails[_landId].longitudeDegreeAfterSale = 0;
        accessLandDetails[_landId].longitudeMinuteAfterSale = 0;
        accessLandDetails[_landId].longitudeSecondAfterSale = 0;
        accessLandDetails[_landId].marketPriceAfterSale = 0;
        accessLandDetails[_landId].radiusAfterSale = 0;
    }

    function _deleteLandDetails(uint _landId) private {
        accessLandDetails[_landId].landOwner = address(0);
        accessLandDetails[_landId].state = "";
        accessLandDetails[_landId].district = "";
        accessLandDetails[_landId].village = "";
        accessLandDetails[_landId].surveyNumber = "";
        accessLandDetails[_landId].subDivisionNumber = "";
        accessLandDetails[_landId].latitudeDegree = 0;
        accessLandDetails[_landId].latitudeMinute = 0;
        accessLandDetails[_landId].latitudeSecond = 0;
        accessLandDetails[_landId].longitudeDegree = 0;
        accessLandDetails[_landId].longitudeMinute = 0;
        accessLandDetails[_landId].longitudeSecond = 0;
        accessLandDetails[_landId].radius = 0;
        accessLandDetails[_landId].areaInCents = 0;
        accessLandDetails[_landId].marketPrice = 0;
        accessLandDetails[_landId].isDryLand = false;
        accessLandDetails[_landId].isForSale = false;
        accessLandDetails[_landId].areaForSale = 0;
        accessLandDetails[_landId].latitudeDegreeOfAreaForSale = 0;
        accessLandDetails[_landId].latitudeMinuteOfAreaForSale = 0;
        accessLandDetails[_landId].latitudeSecondOfAreaForSale = 0;
        accessLandDetails[_landId].longitudeDegreeOfAreaForSale = 0;
        accessLandDetails[_landId].longitudeMinuteOfAreaForSale = 0;
        accessLandDetails[_landId].longitudeSecondOfAreaForSale = 0;
        accessLandDetails[_landId].marketPriceOfAreaForSale = 0;
        accessLandDetails[_landId].radiusOfAreaForSale = 0;
        accessLandDetails[_landId].minOffer = 0;
        accessLandDetails[_landId].verifiedSaleDetails = false;
        accessLandDetails[_landId].hasAnOffer = false;
        accessLandDetails[_landId].buyersAddress = address(0);
        accessLandDetails[_landId].buyersOffer = 0;
        accessLandDetails[_landId].latitudeDegreeAfterSale = 0;
        accessLandDetails[_landId].latitudeMinuteAfterSale = 0;
        accessLandDetails[_landId].latitudeSecondAfterSale = 0;
        accessLandDetails[_landId].longitudeDegreeAfterSale = 0;
        accessLandDetails[_landId].longitudeMinuteAfterSale = 0;
        accessLandDetails[_landId].longitudeSecondAfterSale = 0;
        accessLandDetails[_landId].marketPriceAfterSale = 0;
        accessLandDetails[_landId].radiusAfterSale = 0;
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

    function _removeAssetFromPortfolio(uint _landId, address _landOwner) private {
        uint index = _findIndex(_landId, _landOwner);
        portfolio[_landOwner][index] = portfolio[_landOwner][portfolio[_landOwner].length - 1];
        portfolio[_landOwner].pop();
    }

    function _stringconcat(string memory _string1, string memory _string2) private pure returns (string memory) {
        return(string(abi.encodePacked(_string1, _string2)));
    }

    function _popRequestList() private {
        uint len = requestList.length;
        for (uint i = 1; i < len; i++) {
            requestList[i-1] = requestList[i];
        }
        requestList.pop();
    }

    function _popRequestOfSaleDetails() private {
        uint len = requestOfSaleDetails.length;
        for (uint i = 1; i < len; i++) {
            requestOfSaleDetails[i-1] = requestOfSaleDetails[i];
        }
        requestOfSaleDetails.pop();
    }
}
