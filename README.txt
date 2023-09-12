# supercop-nextbot
Supercop, invades games, by Straw W Wagen.

Requires the Terminator Nextbot.

Convars
  Spawn protection, Bot spawns at player spawnpoints, so this is needed.
  supercop_nextbot_spawnprot_copspawn    Bot won't shoot until it's been alive for this long
  supercop_nextbot_spawnprot_ply         Don't shoot players until they've been alive for this long.

  TTT
  supercop_nextbot_ttt_invadechanceonroundstart    Spawn chance on round start, 0 to never spawn, 100 to always spawn.
  supercop_nextbot_ttt_invadedelay                 How long after the round starts should supercop wait to invade, seconds.
  supercop_nextbot_ttt_invadeonce                  Only allow supercop to invade once per map.

  Anything non-ttt
  supercop_nextbot_generic_invasionchance    Chance for supercop to invade, rolled once every minute, 0 never spawns, 100, always.
  supercop_nextbot_generic_invasionlength    How long in minutes, will supercop invade for? 0 to never despawn.

  Other
  supercop_nextbot_jog                 Should supercop jog
  supercop_nextbot_do_prints           Do supercop prints?
  supercop_nextbot_do_invadingalarm    Do manhack alarm when spawned?

Global Funcs
  supercopNextbot_CopCanInvade()    Finds a spot for supercop to spawn, and if there is none, or there's already an invading supercop, or there's no navmesh, returns false.
  supercopNextbot_CopInvade()       Spawns supercop.
  supercopNextbot_Remove()          Despawns supercop.

Hooks
  supercop_nextbot_blockinvasion         No args. Return true to block supercopNextbot_CopCanInvade from returning true.
  supercop_nextbot_successfulinvasion    No args, runs after invasion succeeds and supercop is spawned.