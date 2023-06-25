pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Address.sol";
import "./Common.sol";
import "./IERC1155TokenReceiver.sol";
import "./IERC1155.sol";

// Contract implementing ERC1155
contract ERC1155 is IERC1155, ERC165, CommonConstants {
    // Utilizing SafeMath library to prevent overflows/underflows
    using SafeMath for uint256;
    // Using the Address library to perform some address-related functions
    using Address for address;

    // Mapping from token id to an address to the amount of tokens of that type the address owns
    mapping (uint256 => mapping(address => uint256)) internal balances;

    // Mapping from owner to operator approvals
    mapping (address => mapping(address => bool)) internal operatorApproval;

    // The interface identifiers for the ERC165 (which includes ERC1155)
    bytes4 constant private INTERFACE_SIGNATURE_ERC165 = 0x01ffc9a7;
    bytes4 constant private INTERFACE_SIGNATURE_ERC1155 = 0xd9b67a26;

    // Override supportsInterface function to whitelist the ERC165 and ERC1155 interfaces
    function supportsInterface(bytes4 _interfaceId) public view returns (bool) {
        return (_interfaceId == INTERFACE_SIGNATURE_ERC165 || _interfaceId == INTERFACE_SIGNATURE_ERC1155);
    }

    // Function to safely transfer tokens from one address to another
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external {
        // Validate _to address
        require(_to != address(0x0), "_to must be non-zero.");

        // Ensure that caller is allowed to transfer tokens
        require(_from == msg.sender || operatorApproval[_from][msg.sender] == true, "Need operator approval for 3rd party transfers.");

        // Use SafeMath to ensure balances do not underflow
        balances[_id][_from] = balances[_id][_from].sub(_value);
        // Use SafeMath to ensure balances do not overflow
        balances[_id][_to]   = _value.add(balances[_id][_to]);

        // Emit transfer event
        emit TransferSingle(msg.sender, _from, _to, _id, _value);

        // Call onERC1155Received if the destination is a contract
        if (_to.isContract()) {
            _doSafeTransferAcceptanceCheck(msg.sender, _from, _to, _id, _value, _data);
        }
    }

    // Function to safely transfer multiple tokens from one address to another
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external {
        require(_to != address(0x0), "destination address must be non-zero.");
        require(_ids.length == _values.length, "_ids and _values array length must match.");
        require(_from == msg.sender || operatorApproval[_from][msg.sender] == true, "Need operator approval for 3rd party transfers.");

        for (uint256 i = 0; i < _ids.length; ++i) {
            uint256 id = _ids[i];
            uint256 value = _values[i];

            // Use SafeMath to prevent underflows
            balances[id][_from] = balances[id][_from].sub(value);
            // Use SafeMath to prevent overflows
            balances[id][_to]   = value.add(balances[id][_to]);
        }

        emit TransferBatch(msg.sender, _from, _to, _ids, _values);

        if (_to.isContract()) {
            _doSafeBatchTransferAcceptanceCheck(msg.sender, _from, _to, _ids, _values, _data);
        }
    }

    // Function to check the balance of a certain owner for a certain id
    function balanceOf(address _owner, uint256 _id) external view returns (uint256) {
        return balances[_id][_owner];
    }

    // Function to check the balance of a certain owners for certain ids
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory) {
        require(_owners.length == _ids.length, "_owners and _ids length must match.");

        uint256[] memory batchBalances = new uint256[](_owners.length);

        for (uint256 i = 0; i < _owners.length; ++i) {
            batchBalances[i] = balances[_ids[i]][_owners[i]];
        }

        return batchBalances;
    }

    // Function to give or revoke permission to a given operator to transfer all tokens of caller
    function setApprovalForAll(address _operator, bool _approved) external {
        operatorApproval[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    // Function to check if an operator is approved to transfer all tokens of an owner
    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return operatorApproval[_owner][_operator];
    }
    
    // Internal function to call onERC1155Received on a contract
    function _doSafeTransferAcceptanceCheck(address _operator, address _from, address _to, uint256 _id, uint256 _value, bytes memory _data) internal {
        require(IERC1155TokenReceiver(_to).onERC1155Received(_operator, _from, _id, _value, _data) == ERC1155_RECEIVED_VALUE, "ERC1155: got unknown value from onERC1155Received");
    }

    // Internal function to call onERC1155BatchReceived on a contract
    function _doSafeBatchTransferAcceptanceCheck(address _operator, address _from, address _to, uint256[] memory _ids, uint256[] memory _values, bytes memory _data) internal {
        require(IERC1155TokenReceiver(_to).onERC1155BatchReceived(_operator, _from, _ids, _values, _data) == ERC1155_BATCH_RECEIVED_VALUE, "ERC1155: got unknown value from onERC1155BatchReceived");
    }
}
