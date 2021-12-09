// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./Equation.sol";

interface BadgeNFT is IERC721 {
    function getRawData(uint256 _tokenId) external view returns (bytes32); 
}

contract TriggerFund is ERC721Holder {
    using Equation for Equation.Node[];
    using Address for address;

    struct Fund {
        address funder;
        uint256 baseAmount;
        uint256 leftAmount;
    }

    Fund[] public funds;

    mapping (uint => BadgeNFT[]) badges;
    mapping (uint => Equation.Node[]) condition;

    event FundCreated(address funder, uint256 baseAmount, uint256 leftAmount);

    constructor () ERC721Holder() {}

    function createFund (uint256 _baseAmount, BadgeNFT[] memory _badges, uint256[] memory _expressions) public payable {
        uint id = funds.length;

        // TODO: check if baseAmount % msg.value == 0
        Fund memory fund = Fund({
            funder: msg.sender,
            baseAmount: _baseAmount,
            leftAmount: msg.value
        });

        // we should store addresses of NFT we plan to use as input for the expression
        badges[id] = _badges;
        condition[id].init(_expressions);

        funds.push(fund);

        emit FundCreated(fund.funder, fund.baseAmount, fund.leftAmount);
    }

    function claim (uint256 _fundId, uint256[] calldata _withTokenIds) public {
        require(checkValid(_fundId, msg.sender, _withTokenIds), "You cannot claim this fund");
        // require(notUsed(_fundId, msg.sender), "This fund is already used");

        Fund memory fund = funds[_fundId];

        // this should fail automatically if not enought money left
        fund.leftAmount = fund.leftAmount - fund.baseAmount;

        Address.sendValue(payable(msg.sender), fund.baseAmount);
    }

    function closeFund(uint256 _fundId) public {
        Fund storage fund = funds[_fundId];

        require(fund.funder == msg.sender, "Only funder can close this fund");

        fund.leftAmount = 0;

        Address.sendValue(payable(msg.sender), fund.leftAmount);
    }

    function checkValid(uint256 _fundId, address _receiver, uint256[] calldata _tokenIds) public view returns (bool) {
        Fund storage fund = funds[_fundId];

        if (fund.leftAmount == 0) {
            return false;
        }

        BadgeNFT[] memory fundBadges = badges[_fundId];

        // uint256[] memory hasBadge;
        // TODO: maybe rawData can be 0 or 1 if you don't need any special value?
        uint256[] memory rawData;

        for (uint256 i = 0; i < fundBadges.length; i++) {
            require(fundBadges[i].ownerOf(_tokenIds[i]) == _receiver, "Not owner of tokenId");
            // hasBadge[i] = fund.badges[i].balanceOf(_receiver) > 0;
            // hasBadge[i] = 
            rawData[i] = uint256(fundBadges[i].getRawData(_tokenIds[i]));
        }

        uint result = condition[_fundId].calculateN(rawData);

        // TODO: use calcBool?
        return result > 0;
    }
}
