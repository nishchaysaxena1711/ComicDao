// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/governance/IGovernor.sol";

abstract contract DaoManager {

    function setGovernor(address _governorAddress) external virtual;
    function getGovernor() public view virtual returns (IGovernor);
    function getProposableType(string memory _proposalFunctionName) pure internal virtual returns (string memory _type);

    modifier requireGovernor(){
        require(address(getGovernor()) != address(0), "Governor address is not set");
        _;
    }

    function bytesToString(bytes memory _bys) private pure returns (string memory) {
        return string(abi.encodePacked(_bys));
    }

    function bytesToAddress(bytes memory _bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(_bys,20))
        } 
    }

    function generateTargets() internal view returns (address[] memory) {
        address[] memory targets = new address[](1);
        targets[0] = address(this);
        return targets;
    }

    function generateCalldatas(string memory _proposalFunctionName, bytes calldata _param) internal pure returns (bytes[] memory) {
        string memory paramType = getProposableType(_proposalFunctionName);
        require(bytes(paramType).length > 0, "Invalid function proposal");
        string memory signature = string(abi.encodePacked(_proposalFunctionName, "(", paramType, ")"));
        bytes[] memory calldatas = new bytes[](1);
        if (keccak256(abi.encodePacked(paramType)) == keccak256("address")) {
            calldatas[0] = abi.encodeWithSignature(signature, bytesToAddress(_param));
        } else if (keccak256(abi.encodePacked(paramType)) == keccak256("string")) {
            calldatas[0] = abi.encodeWithSignature(signature, bytesToString(_param));
        } else {
            calldatas[0] = _param;
        }
        return calldatas;
    }

    function getProposalId(string memory _proposalFunctionName, bytes calldata _param) public view requireGovernor returns (uint) {
        return getGovernor().hashProposal(generateTargets(), new uint256[](1), generateCalldatas(_proposalFunctionName, _param), keccak256("description"));
    }

    function createProposal(string memory _proposalFunctionName, bytes calldata _param) external requireGovernor returns (uint) {
        return getGovernor().propose(generateTargets(), new uint256[](1), generateCalldatas(_proposalFunctionName, _param), "description");
    }
    
    function executeProposal(string memory _proposalFunctionName, bytes calldata _param) external requireGovernor returns (uint) {
        return getGovernor().execute(generateTargets(), new uint256[](1), generateCalldatas(_proposalFunctionName, _param), keccak256("description"));
    }
}