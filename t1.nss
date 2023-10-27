#include "NW_I0_GENERIC"
#include "our_constants"

/*

our modifications:

Heartbeat/master/ hello world
Heartbeat/figher/ action move to location
Heartbeat/master/ hearbeat counter printing
T1userdefined/event/death/ location

*/

/*

Notes

all team members have the same AI, define exceptions to have character specific actions

event based actions

events:
- combat
- heartbeat
- spawn
- initialize
- userdefined

queue
- can clear queue to perform a our action instead of predefined bioware actions, only recommended at very specific case

How this AI works
1.  npc spawns and gets a random target
2.  upon heartbeat checks sensibility of target
    if not target is not sensible get new random target
    if more than 0.5 meter away form target keep moving to the target

data types: string, integer, float
boolean doesnt exist
TRUE and FALSE are integers
list can only be imitated

store data
in NPC - local variable, deleted upon death
in Objects (waypoints, spawnpoints) - permanent (only use our team's objects)

locate errors
click on any file, add a space somewhere, save, console shows error location in T2.nss 
consult professor
compile code and build module regularly - to make locating possible errors easier

Move functions
ActionForceMoveToLocation and ActionForceMoveToLocationObject are cheating functions - Teleport
ActionMoveToLocation - can be used always
ActionMoveToObject - can be used to follow an enemy

All Action function go to the action queue

If there are two variations
SpeakString - direct
ActionSpeakString - goes to action queue
can be used for make action delayed from heartbeat and thus control characters more frequently

some useful functions are at the file "our_constants"
Helpfile - NWN Lexicon
Search function
Example is usually the implementation we look for
Alternative functions shown

*/


// Called every time that the AI needs to take a combat decision. The default is
// a call to the NWN DetermineCombatRound.
// (everytime upon being attacked, spotting an enemy, last round was a combat round)
// combat actions are very appropiate, defined by a complex code of bioware
// lets leave it as it is
// later adapt for special cases

void T1_DetermineCombatRound( object oIntruder = OBJECT_INVALID, int nAI_Difficulty = 10 )
{
    DetermineCombatRound( oIntruder, nAI_Difficulty );
}

// Called every heartbeat (i.e., every six seconds).
void T1_HeartBeat()
{
    /*
    Test how to perfrom ActionMoveToLocation

    if (IsFighter())

        string sTarget = GetRandomTarget();
        SetLocalString( OBJECT_SELF, "TARGET", sTarget );
        ActionMoveToLocation( GetLocation( GetObjectByTag( sTarget ) ), TRUE );

        ActionMoveToLocation( WP_ALTAR_BLUE_1, int bRun=FALSE);
        return;
    */

    // a function from tutorial 5
    // count number of heartbeats for master
    // if masters dies, respawning master is a new object
    // store information in spawn portals if its needed after death too (eg PORTAL_BLUE_4)
    // only store information in our team's objects 
    if (IsMaster())
    {
        // returns 0 if no variable 'HBCOUNT' exists, that is no heartbeats have happened yet
        int iHBcount = GetLocalInt( OBJECT_SELF, "HBCOUNT" );
        iHBcount++;
        SetLocalInt( OBJECT_SELF, "HBCOUNT", iHBcount);
        SpeakString("HB count: "+IntToString( iHBcount), TALKVOLUME_SHOUT );
    }

    // hello world test
    if  (IsMaster())
        SpeakString("hello world", TALKVOLUME_SHOUT);

    if (GetIsInCombat())
        return;

    // when its not 'sensible' to keep current target 
    // get random target that is an altair or the doubler
    // reasonably efficient code
    string sTarget = GetLocalString( OBJECT_SELF, "TARGET" );
    if (sTarget == "")
        return;

    // get the object the belongs to the tag of the waypoint
    // tags need to be unique, default tags are all unique
    object oTarget = GetObjectByTag( sTarget );
    // test if object is valid
    // not necessary, just for safety
    // every object is valid in this environment
    if (!GetIsObjectValid( oTarget ))
        return;


    // check if target is a 'sensible' target

    // If there is a member of my own team close to the target and closer than me,
    // and no enemy is closer and this other member is not in combat and
    // has the same target, then choose a new target.
    float fToTarget = GetDistanceToObject( oTarget );
    int i = 1;
    int bNewTarget = FALSE;
    // check if there is an ally close to the target
    // any creatures - OBJECT_TYPE_CREATURE
    // i - return i number of closest objects to location
    object oCreature = GetNearestObjectToLocation( OBJECT_TYPE_CREATURE, GetLocation( oTarget ), i );
    while (GetIsObjectValid( oCreature ))
    {
        // check if closest creature to location is me
        if (GetLocation( oCreature ) == GetLocation( OBJECT_SELF ))
            break;
        // if the distance between the location and the target is bigger than my location I that player stops (?)
        if (GetDistanceBetween( oCreature, oTarget ) > fToTarget)
            break;
        if (GetDistanceBetween( oCreature, oTarget ) > 5.0)
            break;
        // if the creature closer than 5m to the target is an enemy, then move and fight
        if (!SameTeam( oCreature ))
            break;
        // if this creature is in combat I continue moving to the target
        if (GetIsInCombat( oCreature ))
            break;
        // an ally is close enough to the target. assume its mnoving towards the target. Get new target for me
        if (GetLocalString( oCreature, "TARGET" ) == sTarget)
        {
            bNewTarget = TRUE;
            break;
        }
        // if still in loop check next creature
        ++i;
        // get next nearest creature to target
        oCreature = GetNearestObjectToLocation( OBJECT_TYPE_CREATURE, GetLocation( oTarget ), i );
        // back to top
    }

    // get new random target if new rarget is needed
    if (bNewTarget)
    {
        sTarget = GetRandomTarget();
        SetLocalString( OBJECT_SELF, "TARGET", sTarget );
        oTarget = GetObjectByTag( sTarget );
        if (!GetIsObjectValid( oTarget ))
            return;
        fToTarget = GetDistanceToObject( oTarget );
    }

    // continue moving to the target if more than 0.5 meter away from it currently
    // repeat the sending of action to npc, since it could have been interrupted by a combat which is finished, or get pushed of etc
    if (fToTarget > 0.5)
        ActionMoveToLocation( GetLocation( oTarget ), TRUE );

    return;
}

// Called when the NPC is spawned.
void T1_Spawn()
{
    // store target in a string
    string sTarget = GetRandomTarget();
    // remember target, set a local string variable to the target
    // params: object, name, value
    SetLocalString( OBJECT_SELF, "TARGET", sTarget );
    // move to target's location
    ActionMoveToLocation( GetLocation( GetObjectByTag( sTarget ) ), TRUE );
}

// This function is called when certain events take place, after the standard
// NWN handling of these events has been performed.
void T1_UserDefined( int Event )
{
    switch (Event)
    {
        // The NPC has just been attacked.
        case EVENT_ATTACKED:
            break;

        // The NPC was damaged.
        case EVENT_DAMAGED:
            break;

        // At the end of one round of combat.
        case EVENT_END_COMBAT_ROUND:
            break;

        // Every heartbeat (i.e., every six seconds).
        case EVENT_HEARTBEAT:
            T1_HeartBeat();
            break;

        // Whenever the NPC perceives a new creature.
        case EVENT_PERCEIVE:
            break;

        // When a spell is cast at the NPC.
        case EVENT_SPELL_CAST_AT:
            break;

        // Whenever the NPC's inventory is disturbed.
        case EVENT_DISTURBED:
            break;

        // Whenever the NPC dies.
        case EVENT_DEATH:

            // 'print' location 
            SpeakString("Location: " +LocationToString(GetLocation(OBJECT_SELF)), TALKVOLUME_SHOUT );

            break;

        // When the NPC has just been spawned.
        case EVENT_SPAWN:
            T1_Spawn();
            break;
    }

    return;
}

// Called when the fight starts, just before the initial spawning.
void T1_Initialize( string sColor )
{
    // give a name 
    SetTeamName( sColor, "Default-" + GetStringLowerCase( sColor ) );
}