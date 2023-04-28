// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";

// https://etherscan.io/address/0xcd5485b34c9902527bbee21f69312fe2a73bc802#code

// File: contracts/MultiTransfer.sol

/*
    Copyright 2020, Oleg Abrosimov <support@ethereumico.io>
    Based on work by: Jordi Baylina, Adrià Massanet, Alon Bukai

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/// @notice Transfer Ether to multiple addresses
contract MultiTransfer is Pausable {
    // using SafeMath for uint256;

    /// @notice Send to multiple addresses using two arrays which
    ///  includes the address and the amount.
    ///  Payable
    /// @param _addresses Array of addresses to send to
    /// @param _amounts Array of amounts to send
    function multiTransfer_OST(
        address payable[] calldata _addresses,
        uint256[] calldata _amounts
    ) external payable whenNotPaused returns (bool) {
        // require(_addresses.length == _amounts.length);
        // require(_addresses.length <= 255);
        uint256 _value = msg.value;
        for (uint8 i; i < _addresses.length; i++) {
            _value = _value - _amounts[i];

            // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
            /*(success, ) = */ _addresses[i].call{value: _amounts[i]}("");
            // we do not care. caller should check sending results manually and re-send if needed.
        }
        return true;
    }

    /// @notice Send to two addresses
    ///  Payable
    /// @param _address1 Address to send to
    /// @param _amount1 Amount to send to _address1
    /// @param _address2 Address to send to
    /// @param _amount2 Amount to send to _address2
    function transfer2(
        address payable _address1,
        uint256 _amount1,
        address payable _address2,
        uint256 _amount2
    ) external payable whenNotPaused returns (bool) {
        uint256 _value = msg.value;
        _value = _value - (_amount1);
        _value = _value - (_amount2);

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        /*(success, ) = */ _address1.call{value: _amount1}("");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        /*(success, ) = */ _address2.call{value: _amount2}("");

        return true;
    }
}
