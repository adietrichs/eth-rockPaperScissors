contract RockPaperScissors {
    enum Action {Rock, Paper, Scissors}

    struct Game {
        address[2] players;
        bytes32[2] blindedActions;
        Action[2] actions;
        bool[2] revealed;
        uint value;
        uint revealTime;
        bool started;
        bool withdrawn;
    }

    uint[3] public stake;

    Game[][4]

    function RockPaperScissors(uint[3] _stake) {
        stake = _stake;
    }
}

contract myTest {
    uint[][3] public myStore;

    function add(uint _i, uint _newValue) {
        myStore[_i].push(newValue)
    }

    function set(uint _i, uint _j, uint _newValue) {
        myStore[_i][_j] = _newValue;
    }
}


contract RockPaperScissors {
    enum Actions { Rock, Paper, Scissors }
    enum Players { Player1, Player2 }

    struct Game {
        mapping (Players => address) players;
        mapping (Players => bytes32) blindedActions;
        mapping (Players => Actions) actions;
        uint value;
        bool started;
        bool revealed;
        uint revealTime;
        bool finished;
    }

    uint constant waitForReveal = 1 day;

    Game[] public games;

    mapping (address => uint) public balances;

    modifier withoutEther() {
        if (msg.value > 0) throw;
        _
    }

    modifier withEther() {
        if (msg.value == 0) throw;
        _
    }

    modifier validGameID(uint _gameID) {
        if (games.length <= _gameID) throw;
        _
    }

    function createGame(bytes32 _blindedAction) withEther {
        var i = games.length++;
        Game g = games[i];
        g.players[Player1] = msg.sender;
        g.blindedActions[Player1] = _blindedAction;
        g.value = msg.value;
    }

    function cancelGame(uint _gameID) withoutEther validGameID(_gameID) {
        Game g = games[_gameID];
        if (g.players[Player1] != msg.sender || g.started) throw;

    }

    function joinGame(uint _gameID, bytes32 _blindedAction) withEther validGameID(_gameID) {
        Game g = games[_gameID];
        if (g.started) throw;
        g.players[Player2] = msg.sender;
        g.blindedActions[Player2] = _blindedAction;
        if (g.value > msg.value) {
            balances[g.players[Player1]] += g.value - msg.value;
            g.value = msg.value;
        }
        else if (g.value < msg.value) {
            balances[msg.sender] += msg.value - g.value;
        }
        g.started = true;
    }

    function withdraw() withoutEther {
        var amount = balances[msg.sender];
        balances[msg.sender] = 0;
        if (!msg.sender.send(amount))
            throw;
    }

    function () {
        throw;
    }
}
