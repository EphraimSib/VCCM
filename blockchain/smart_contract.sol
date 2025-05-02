pragma solidity ^0.8.0;

contract SecurityLog {
    struct LogEntry {
        uint256 timestamp;
        string eventDescription;
        address reporter;
    }

    LogEntry[] public logs;

    event LogAdded(uint256 indexed index, uint256 timestamp, string eventDescription, address reporter);

    function addLog(string memory eventDescription) public {
        LogEntry memory newLog = LogEntry({
            timestamp: block.timestamp,
            eventDescription: eventDescription,
            reporter: msg.sender
        });
        logs.push(newLog);
        emit LogAdded(logs.length - 1, block.timestamp, eventDescription, msg.sender);
    }

    function getLogCount() public view returns (uint256) {
        return logs.length;
    }

    function getLog(uint256 index) public view returns (uint256, string memory, address) {
        require(index < logs.length, "Invalid log index");
        LogEntry storage logEntry = logs[index];
        return (logEntry.timestamp, logEntry.eventDescription, logEntry.reporter);
    }
}
