contract RockPaperScissors {
    enum Action {Rock, Paper, Scissors}

    struct Game {
        address[2] players;
        bytes32[2] blindedActions;
        Action[2] actions;
        bool[2] revealed;
        uint stake;
        uint revealTime;
        bool started;
        bool cancelled;
        bool withdrawn;
    }

    uint[3] public stake;

    Game[][3] public publicGames;
    bool[3] gameOpen;
    mapping (address => Game[]) public customGames;
    mapping (address => Game[]) public privateGames;

    function RockPaperScissors(uint[3] _stake) {
        stake = _stake;
    }

    function play(bytes32 _blindedAction) {
        uint stakeType;
        if (stake[0] == msg.value) stakeType = 0;
        else if (stake[1] == msg.value) stakeType = 1;
        else if (stake[2] == msg.value) stakeType = 2;
        else throw;

        if (gameOpen[stakeType]) {
            Game openGame = publicGames[stakeType][publicGames[stakeType].length - 1];
            joinGame(openGame, _blindedAction);
            gameOpen[stakeType] = false;
        }
        else {
            publicGames[stakeType].push(createGame(_blindedAction));
            gameOpen[stakeType] = true;
        }
    }

    function cancel(uint _stakeType, uint _gameID) {
        if (_stakeType > 2 || _gameID >= publicGames[_stakeType].length) throw;
        Game[] game = publicGames[_stakeType][_gameID];
        if (game.started) throw;
        game.cancelled = true;
    }

    function createGame(bytes32 _blindedAction) private constant returns (Game _game) {
        _game.players[0] = msg.sender;
        _game.blindedActions[0] = _blindedAction;
        _game.stake = msg.value;
    }

    function joinGame(Game storage _game, bytes32 _blindedAction) private {
        if (_game.started || _game.cancelled) throw;
        _game.players[1] = msg.sender;
        _game.blindedActions[1] = _blindedAction;
        _game.started = true;
    }
}
