/**
 * ============================================================================
 * ASTROCADE LIBRARY (lib) - API REFERENCE
 * ============================================================================
 *
 * The lib object is automatically available in your game code via "lib"
 * This is READ-ONLY reference documentation - lib code is owned by Astrocade.
 *
 * Your game's entry point:
 *
 *   function run(mode) {
 *     // mode is 'edit' or 'play'
 *     // window.gameConfig is already set up before run() is called
 *   }
 * 
 * If you remove this function the game will not run.
 */


/* ============================================================================
 * TYPE DEFINITIONS
 * ============================================================================ */

/**
 * @typedef {Object} LeaderboardEntry
 * @property {string} username - The player's username
 * @property {string|null} profilePicture - URL to profile picture, or null
 * @property {number} score - The player's score
 */

/**
 * @typedef {Object} LeaderboardResponse
 * @property {LeaderboardEntry[]} entries - Array of leaderboard entries
 * @property {number|null} userRank - Current user's rank, or null if not ranked
 * @property {boolean} [success] - Whether the operation succeeded
 */

/**
 * @typedef {Object} UserGameStateResponse
 * @property {string} userId - The user's ID
 * @property {string} gameId - The game's ID
 * @property {Object|null} state - The saved state, or null if none exists
 * @property {boolean} [success] - Whether the operation succeeded
 */

/**
 * @typedef {Object} AnimationPlayer
 * @property {function(number): void} update - Advances animation based on timestamp
 * @property {function(CanvasRenderingContext2D, number, number, number, number): void} draw - Draws current frame
 * @property {function(): {index: number, frame: {x: number, y: number, w: number, h: number}|undefined, total: number}} getCurrentFrame - Gets current frame info
 * @property {function(): void} reset - Resets animation to first frame
 */


/* ============================================================================
 * GLOBALS
 * ============================================================================ */

/**
 * The game's configuration state.
 * Automatically available before run() is called.
 * In edit mode, changes are tracked for undo/redo.
 *
 * @type {Object}
 */
var gameConfig = window.gameConfig;

/**
 * Current game mode. Use to conditionally enable editor features.
 *
 * @type {'edit' | 'play'}
 */
var mode = window.mode;


/* ============================================================================
 * CORE FUNCTIONS
 * ============================================================================ */

/**
 * Retrieves an asset by its ID from the asset map.
 *
 * @param {string} id - The asset ID
 * @returns {Object|undefined} The asset object, or undefined if not found
 */
lib.getAsset = function(id) {};


/* ============================================================================
 * ANIMATION
 * ============================================================================ */

/**
 * Creates an animation player for sprite sheet animations.
 * The assetId should reference an asset with animation data.
 *
 * @param {string} assetId - The animation asset ID
 * @returns {AnimationPlayer|null} The animation player, or null if not found
 *
 * @example
 * const anim = lib.getAnimationPlayer('player_run');
 * function gameLoop(timestamp) {
 *   anim.update(timestamp);
 *   anim.draw(ctx, x, y, 64, 64);
 *   requestAnimationFrame(gameLoop);
 * }
 */
lib.getAnimationPlayer = function(assetId) {};

/**
 * Preloads an animation's sprite sheet for smoother playback.
 * Call during initialization to avoid loading delays.
 *
 * @param {string} assetId - The animation asset ID
 * @returns {Promise<void>}
 */
lib.preloadAnimation = async function(assetId) {};


/* ============================================================================
 * LEADERBOARD
 * ============================================================================ */

/**
 * Submits the current player's score to the game's leaderboard.
 * Throws if game is not saved or user is not authenticated.
 *
 * @param {number} score - The player's score
 * @param {number} [numEntries] - Optional: number of top entries to return
 * @returns {Promise<LeaderboardResponse>}
 */
lib.addPlayerScoreToLeaderboard = async function(score, numEntries) {};

/**
 * Retrieves the top N entries from the game's leaderboard.
 *
 * @param {number} [numEntries] - Optional: number of entries to retrieve
 * @returns {Promise<LeaderboardResponse>}
 */
lib.getTopNEntriesFromLeaderboard = async function(numEntries) {};


/* ============================================================================
 * USER GAME STATE (Save/Load)
 * ============================================================================ */

/**
 * Persists the user's game progress to the server.
 * State must be JSON-serializable (no functions, circular refs, etc).
 * Each user has one save slot per game.
 *
 * @param {Object} state - The game state to save
 * @returns {Promise<UserGameStateResponse>}
 */
lib.saveUserGameState = async function(state) {};

/**
 * Retrieves the user's previously saved game state.
 *
 * @returns {Promise<UserGameStateResponse>}
 */
lib.getUserGameState = async function() {};

/**
 * Deletes the user's saved game state.
 * Use for "New Game" or reset functionality.
 *
 * @returns {Promise<{success: boolean}>}
 */
lib.deleteUserGameState = async function() {};
