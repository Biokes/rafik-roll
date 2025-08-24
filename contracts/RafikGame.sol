// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface IRafikGenerator {
    function requestRandomWords(bool enableNativePayment) external returns (uint256 requestId);
    function getRequestStatus(uint256 _requestId) external view returns (bool fulfilled, uint256[] memory randomWords);
}

contract RafikGame {
    IRafikGenerator public generator;

    // mapping player => last request id
    mapping(address => uint256) public playerRequest;

    event RandomRequested(address indexed player, uint256 requestId);
    event RandomResolved(address indexed player,uint256 requestId,uint256 randomValue);

    constructor(address generatorAddress) {
        generator = IRafikGenerator(generatorAddress);
    }

    function requestRandomForPlayer(bool enableNativePayment) external {
        uint256 id = generator.requestRandomWords(enableNativePayment);
        playerRequest[msg.sender] = id;
        emit RandomRequested(msg.sender, id);
    }

    // anyone can call to resolve the random once fulfilled (pull/poll pattern)
    // this reads from the generator and emits the resolved value for on-chain use.
    function resolveRandomForPlayer(address player) external {
        uint256 reqId = playerRequest[player];
        require(reqId != 0, "no request for player");
        (bool fulfilled, uint256[] memory words) = generator.getRequestStatus(reqId);
        require(fulfilled, "not fulfilled yet");

        // use first word as the random value
        uint256 random = words.length > 0 ? words[0] : 0;

        // example: map to range 0..99
        uint256 value = random % 100;

        emit RandomResolved(player, reqId, value);

        // clear stored request
        delete playerRequest[player];
    }
}
