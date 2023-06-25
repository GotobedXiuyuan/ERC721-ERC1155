// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC721
{
  // This event is emitted when ownership of a token changes. 
  // The _from address is the previous owner, the _to address is the new owner, 
  // and the _tokenId is the ID of the token.
  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 indexed _tokenId
  );

  // This event is emitted when an address gets approval to transfer a token. 
  // The _owner address is the owner of the token, the _approved address is the address 
  // that got approval, and the _tokenId is the ID of the token.
  event Approval(
    address indexed _owner,
    address indexed _approved,
    uint256 indexed _tokenId
  );

  // This event is emitted when an operator is enabled or disabled for an owner. 
  // The operator can manage all tokens of the owner. _approved is true if the operator 
  // is approved, false if it is not.
  event ApprovalForAll(
    address indexed _owner,
    address indexed _operator,
    bool _approved
  );

  // This function is used to safely transfer a token from one address to another, with additional data.
  // The function checks if the _to address can manage the token.
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  )
    external;

  // This function is similar to the previous one, but without additional data.
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external;

  // This function is used to transfer a token from one address to another. 
  // This function does not include the safety checks of safeTransferFrom.
  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external;

  // This function allows an owner to approve someone else to manage their token. 
  // The _approved address is the address that gets approval, and the _tokenId is the ID of the token.
  function approve(
    address _approved,
    uint256 _tokenId
  )
    external;

  // This function allows an owner to approve or revoke approval for an operator 
  // to manage all their tokens. _approved is true if the operator is approved, false if not.
  function setApprovalForAll(
    address _operator,
    bool _approved
  )
    external;

  // This function returns the number of tokens an address owns.
  function balanceOf(
    address _owner
  )
    external
    view
    returns (uint256);

  // This function returns the owner of a token.
  function ownerOf(
    uint256 _tokenId
  )
    external
    view
    returns (address);

  // This function returns the address that is approved to manage a specific token.
  function getApproved(
    uint256 _tokenId
  )
    external
    view
    returns (address);

  // This function checks if an operator is approved to manage all tokens of an owner.
  // It returns true if the operator is approved, false if not.
  function isApprovedForAll(
    address _owner,
    address _operator
  )
    external
    view
    returns (bool);
}
