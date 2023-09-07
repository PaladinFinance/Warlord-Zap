// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {Surl} from "surl/Surl.sol";
import {stdJson} from "forge-std/StdJson.sol";

contract OneInchQuotes is Test {
    using Surl for *;
    using stdJson for string;

    function fetchPrice(address src, address dst, uint256 amount) public returns (uint256) {
        string memory url = "https://api.1inch.dev/swap/v5.2/1/quote";
        string memory params = string.concat(
            "?from=",
            vm.toString(address(0)),
            "&src=",
            vm.toString(src),
            "&dst=",
            vm.toString(dst),
            "&amount=",
            vm.toString(amount)
        );

        string memory apiKey = vm.envString("ONEINCH_API_KEY");

        string[] memory headers = new string[](2);
        headers[0] = "accept: application/json";
        headers[1] = string.concat("Authorization: Bearer ", apiKey);

        string memory request = string.concat(url, params);
        (uint256 status, bytes memory res) = request.get(headers);

        assertEq(status, 200, "Couldn't fetch price from 1inch API");

        string memory json = string(res);

        return json.readUint(".toAmount");
    }
}
