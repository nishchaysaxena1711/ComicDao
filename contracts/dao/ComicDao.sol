// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/governance/IGovernor.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./DaoManager.sol";
import "../coin/Comic.sol";

contract ComicDao is Ownable, DaoManager {

    event sketchOfAnIdeaPayment(uint ideaId, uint amount, address to);
    event drawingOfAnSketchPayment(string sketchUrl, uint amount, address to);

    mapping(address => bool) public writers;
    mapping(address => bool) public artists;
    mapping(uint => string) public sketchOfAnIdea;
    mapping(string => string) public drawingOfAnSketch;
    string[] public ideas;
    uint completedDrawings;

    Comic private coin;
    IGovernor private governor;

    modifier onlyGovernor() {
        require(msg.sender == address(governor), "Sender is not a governor");
        _;
    }

    function setCoinAddress(address _coin) external {
        require(_coin != address(0), 'Coin address cannot be zero address');
        coin = Comic(_coin);
    }

    function addOrRemoveWriter(address _writerAddress) external onlyGovernor {
        if (writers[_writerAddress] == true) {
            writers[_writerAddress] = false;
        } else {
            writers[_writerAddress] = true;
        }
    }

    function addOrRemoveArtist(address _artistAddress) external onlyGovernor {
        if (artists[_artistAddress] == true) {
            artists[_artistAddress] = false;
        } else {
            artists[_artistAddress] = true;
        }
    }

    function addIdeas(string memory _newIdea) external onlyGovernor {
        ideas.push(_newIdea);
    }

    function submitSketch(uint _ideaId, string memory _sketchUrl) external {
        require(writers[msg.sender] == true, "Sender is not a approved writer");
        require(bytes(sketchOfAnIdea[_ideaId]).length > 0, "Sketch is already submitted");

        sketchOfAnIdea[_ideaId] = _sketchUrl;

        uint _paymentAmount = address(this).balance / 100;
        require(_paymentAmount > 0);
        (bool sent,) = msg.sender.call{value: _paymentAmount}("");
        require(sent, "Payment failed");

        emit sketchOfAnIdeaPayment(_ideaId, _paymentAmount, msg.sender);
    }

    function submitDrawing(string memory _sketchUrl, string memory _drawingUrl) external {
        require(artists[msg.sender] == true, "Sender is not a approved artist");
        require(bytes(drawingOfAnSketch[_sketchUrl]).length > 0, "Drawing is already submitted");

        drawingOfAnSketch[_sketchUrl] = _drawingUrl;
        completedDrawings++;

        uint _paymentAmount = address(this).balance / 100;
        require(_paymentAmount > 0);
        (bool sent,) = msg.sender.call{value: _paymentAmount}("");
        require(sent, "Payment failed");

        emit drawingOfAnSketchPayment(_sketchUrl, _paymentAmount, msg.sender);
    }

    function contribute() external payable {
        require(msg.value > 0, "Contribution should be > 0");
        // reverse cashback feature of e-shopping sites -> The more shopping, more will be rewards
        uint coinsToMint = msg.value - (sqrt(completedDrawings + 1) / msg.value);
        coin.mint(msg.sender, coinsToMint);
    }

    function sqrt(uint x) private pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    // DAO manager override method impl

    function setGovernor(address _governorAddress) external override onlyOwner {
        require(_governorAddress != address(0), 'Governor address cannot be zero address');
        governor = IGovernor(_governorAddress);
    }
    
    function getProposableType(string memory _proposalFunctionName) pure internal override returns (string memory _type) {
        if (keccak256(abi.encodePacked(_proposalFunctionName)) == keccak256("addIdeas")) {
            _type = "string";
        } else if ((keccak256(abi.encodePacked(_proposalFunctionName)) == keccak256("addOrRemoveArtist")) || 
            (keccak256(abi.encodePacked(_proposalFunctionName)) == keccak256("addOrRemoveWriter"))) {
            _type = "address";
        }

        return _type;
    }

    function getGovernor() public view override returns (IGovernor) {
        return governor;
    }
}
