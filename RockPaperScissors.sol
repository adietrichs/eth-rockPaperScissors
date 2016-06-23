contract RockPaperScissors {

    // admin stuff

    address public owner;
    uint public publicStake;

    function RockPaperScissors(uint _publicStake) {
        owner = msg.sender;
        publicStake = _publicStake;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) throw;
        _
    }

    modifier noEther() {
        if (msg.value != 0) throw;
        _
    }

    function setAdmin(address _owner) onlyOwner noEther {
        owner = _owner;
    }

    function setPublicStake(uint _publicStake) onlyOwner noEther {
        if (publicStake != _publicStake) {
            if (publicOpenGame) {
                cancelGame(publicGameID);
            }
            publicStake = _publicStake;
        }
    }


    // balance stuff

    mapping (address => uint) public balanceOf;

    function withdraw() noEther {
        uint toSend = balanceOf[msg.sender];
        balanceOf[msg.sender] = 0;
        if (!msg.sender.send(toSend)) throw;
    }


    // game stuff

    enum Action {Rock, Paper, Scissors}

    struct Game {
        address[2] players;
        bytes32[2] blindedActions;
        Action[2] actions;
        bool[2] revealed;
        uint stake;
        uint revealTime;
        bool started;
        bool finished;
    }

    Game[] public games;

    uint public publicGameID;
    bool public publicOpenGame;

    mapping (address => uint[]) public gamesOf;

    modifier validGameID(uint _gameID) {
        if (_gameID >= games.length) throw;
        _
    }

    function play(bytes32 _blindedAction) {
        if (msg.value != publicStake) throw;
        if (publicOpenGame) {
            joinGame(publicGameID, _blindedAction);
            publicOpenGame = false;
        }
        else {
            uint gameID = createGameAgainst(0x0, _blindedAction);
            publicGameID = gameID;
            publicOpenGame = true;
        }
    }

    function createGameAgainst(address _player2, bytes32 _blindedAction) returns(uint _gameID) {
        _gameID = games.length++;
        gamesOf[msg.sender].push(_gameID);
        Game g = games[_gameID];
        g.players[0] = msg.sender;
        g.players[1] = _player2;
        g.blindedActions[0] = _blindedAction;
        g.stake = msg.value;
    }

    function createGame(bytes32 _blindedAction) {
        createGameAgainst(0x0, _blindedAction);
    }

    function cancelGame(uint _gameID) noEther validGameID(_gameID) {
        Game g = games[_gameID];
        if (g.started || g.players[0] != msg.sender && g.players[0] != owner) throw;
        if (publicOpenGame && publicGameID == _gameID) publicOpenGame = false;
        g.started = true;
        g.finished = true;
        balanceOf[msg.sender] += g.stake;
    }

    function joinGame(uint _gameID, bytes32 _blindedAction) validGameID(_gameID) {
        Game g = games[_gameID];
        if (g.players[1] != 0x0 && g.players[1] != msg.sender || g.stake != msg.value) throw;
        g.players[1] = msg.sender;
        g.blindedActions[1] = _blindedAction;
        g.started = true;
    }

    function reveal(uint _gameID, Action _action, bytes32 _secret) noEther validGameID(_gameID) {
        Game g = games[_gameID];
        if (!g.started || g.finished || g.players[0] != msg.sender && g.players[1] != msg.sender) throw;
        uint player = g.players[0] == msg.sender ? 0 : 1;
        if (g.revealed[player] || sha3(_action, _secret) != g.blindedActions[player]) throw;
        g.actions[player] = _action;
        g.revealed[player] = true;
        if (g.revealTime == 0) {
            g.revealTime = now;
        }
        else {
            if (g.actions[0] == g.actions[1]) {
                balanceOf[g.players[0]] += g.stake;
                balanceOf[g.players[1]] += g.stake;
            }
            else {
                uint winner = g.actions[0] == Action.Rock && g.actions[1] == Action.Scissors ||
                              g.actions[0] == Action.Paper && g.actions[1] == Action.Rock ||
                              g.actions[0] == Action.Scissors && g.actions[1] == Action.Paper ? 0 : 1;
                balanceOf[g.players[winner]] += 2 * g.stake;
            }
            g.finished = true;
        }
    }

    function forceFinishGame(uint _gameID) noEther validGameID(_gameID) {
        Game g = games[_gameID];
        if (!g.started || g.finished || g.players[0] != msg.sender && g.players[1] != msg.sender || now < g.revealTime + 1 days) throw;
        balanceOf[msg.sender] += 2 * g.stake;
        g.finished = true;
    }


    // constant helper functions

    function getGamePlayerDetails(uint _gameID, uint _player) validGameID(_gameID) constant returns(address _players, bytes32 _blindedActions, Action _actions, bool _revealed) {
        if (_player > 1) throw;
        Game g = games[_gameID];
        _players = g.players[_player];
        _blindedActions = g.blindedActions[_player];
        _actions = g.actions[_player];
        _revealed = g.revealed[_player];
    }

    function blindAction(Action _action, string _random) constant returns(bytes32 _secret, bytes32 _blindedAction) {
        _secret = sha3(_random, now);
        _blindedAction = sha3(_action, _secret);
    }


    // disable donations

    function () {
        throw;
    }
}
