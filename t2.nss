#include "NW_I0_GENERIC"
#include "our_constants"

// -------------------------------------------------------------------------------------------------------------------------------
// Our focus is at directing our creatures to the "right" altars
// this is done here by applying conditions that set scores to the altars
// MODIFY ONLY THIS PART
// experiment with specifying different score altering measurements coming from realtime game statistics
// eg. distance to altar, altar occupation status
// set creature specific behaviour
// DO NOT CHANGE OTHER PARTS FOR NOW
// push changes to a new branch to this github repository
// ask anything else you need to know:)

// assign scores to target locations
// based self distance to altar and 'friendly' status of altar
float GetLocScore( string sAltar ) {
    int friendlyAltarControl = ClaimerOf( sAltar ) == MyColor();
    if (friendlyAltarControl == TRUE) {
        return -999.9;
    }

    object oAltar = GetObjectByTag( sAltar );
    float score = 0.0 - GetDistanceBetween(OBJECT_SELF, oAltar);
    return score;
}

string sDoubler = WpDoubler();
string sClosestLeft = WpClosestAltarLeft();
string sClosetsRight = WpClosestAltarRight();
string sFurthestLeft = WpFurthestAltarLeft();
string sFurthestRight = WpFurthestAltarRight();

int ourPointsPerHeartBeat( ){
    int count = 0;
    if ( ClaimerOf( sClosestLeft ) == MyColor() ) {
        count += 1;
    }
    if ( ClaimerOf( sClosetsRightAltar ) == MyColor() ) {
        count += 1;
    }
    if ( ClaimerOf( sFurthestLeft ) == MyColor() ) {
        count += 1;
    }
    if ( ClaimerOf( sFurthestRight ) == MyColor() ) {
        count += 1;
    }
    if ( ClaimerOf( sDoubler ) == MyColor() ) {
        count = count * 2;
    }
    return count;
}


int opponentPointsPerHeartBeat( ){
    int count = 0;
    if ( ClaimerOf( sClosestLeft ) == OpponentColor() ) {
        count += 1;
    }
    if ( ClaimerOf( sClosetsRightAltar ) == OpponentColor() ) {
        count += 1;
    }
    if ( ClaimerOf( sFurthestLeft ) == OpponentColor() ) {
        count += 1;
    }
    if ( ClaimerOf( sFurthestRight ) == OpponentColor() ) {
        count += 1;
    }
    if ( ClaimerOf( sDoubler ) == OpponentColor() ) {
        count = count * 2;
    }
    return count;
}

int closestAltarLeftEmpty(){
    if ( ClaimerOf( sClosestLeft ) == "" ) {
        return True;
    }
    return False;
}

int closestAltarRightEmpty(){
    if ( ClaimerOf( sClosetsRightAltar ) == "" ) {
        return true;
    }
    return false;
}

int furthestAltarLeftEmpty( ){
    if ( ClaimerOf( sFurthestLeft ) == "" ) {
        return true;
    }
    return false;
}

int furthestAltarRightEmpty( ){
    if ( ClaimerOf( sFurthestRight ) == "" ) {
        return true;
    }
    return false;
}

int doublerEmpty( ){
    if (  ClaimerOf( sDoubler ) == "" ) {
        return true;
    }
    return false;
}

int emptyAltarExists( ) {
    if ( closestAltarLeftEmpty() == true ) {
        return true;
    }
    if ( closestAltarRightEmpty() == true) {
        return true;
    }
    if ( furthestAltarLeftEmpty() == true) {
        return true;
    }
    if ( furthestAltarRightEmpty() == true) {
        return true;
    }
    if ( doublerEmpty( ) == true ) {
        return true;
    }
    return false;
}


int gameState( ) {
    if ( emptyAltarExists( ) == true ) {
        return 0;
    }
    if (  ourPointsPerHeartBeat() > opponentPointsPerHeartBeat() ) {
        return 1;
    }
    return 2;
}




int gameState( )

string GetGoodTarget()
{
    // The next line moves to the spawn location of the similar opponent
    // ActionMoveToLocation( GetLocation( GetObjectByTag( "WP_" + OpponentColor( OBJECT_SELF ) + "_" + IntToString( GetLocalInt( OBJECT_SELF, "INDEX" ) ) ) ), TRUE );

    // important locations defined with string variables

    /*
    string sDoubler = WpDoubler();
    string sClosestLeft = WpClosestAltarLeft();
    string sClosetsRight = WpClosestAltarRight();
    string sFurthestLeft = WpFurthestAltarLeft();
    string sFurthestRight = WpFurthestAltarRight();
    */

    string best_altar = "";

    // class based 'decision' condition example
    if (IsMaster()) {
        int friendlyAltarControl = ClaimerOf( sDoubler ) == MyColor();
        if (!friendlyAltarControl){
            best_altar = sDoubler;
        }
    }

    // chosse best altar by selecting highest altar score
    if (best_altar == "")
    {
        float scoreDoubler = GetLocScore( sDoubler );
        float best_score = scoreDoubler; // important
        best_altar = sDoubler;

        float scoreClosestLeft = GetLocScore( sClosestLeft );
        if (scoreClosestLeft > best_score) {
            best_score = scoreClosestLeft;
            best_altar = sClosestLeft;
        }
        float scoreClosessRight = GetLocScore( sClosetsRight );
        if (scoreClosessRight > best_score) {
            best_score = scoreClosessRight;
            best_altar = sClosetsRight;
        }
        float scoreFurthestLeft = GetLocScore( sFurthestLeft );
        if (scoreFurthestLeft > best_score) {
            best_score = scoreFurthestLeft;
            best_altar = sFurthestLeft;
        }
        float scoreFurthestRight = GetLocScore( sFurthestRight );
        if (scoreFurthestRight > best_score) {
            best_score = scoreFurthestRight;
            best_altar = sFurthestRight;
        }
    }

    // to do something (select random target) even if no previous conditions were met
    if (best_altar == "") {
        best_altar = GetRandomTarget();
        SpeakString("(failover) going to " + best_altar, TALKVOLUME_SHOUT);
    } else {
        SpeakString("going to " + best_altar, TALKVOLUME_SHOUT);
    }

    return best_altar;
}

// -------------------------------------------------------------------------------------------------------------------------------

// Called every time that the AI needs to take a combat decision. The default is
// a call to the NWN DetermineCombatRound.
void T2_DetermineCombatRound( object oIntruder = OBJECT_INVALID, int nAI_Difficulty = 10 )
{
    DetermineCombatRound( oIntruder, nAI_Difficulty );
}

// Called every heartbeat (i.e., every six seconds).
void T2_HeartBeat()
{
    if (GetIsInCombat())
        return;

    string sTarget = GetLocalString( OBJECT_SELF, "TARGET" );
    if (sTarget == "")
        return;

    object oTarget = GetObjectByTag( sTarget );
    if (!GetIsObjectValid( oTarget ))
        return;

    // If there is a member of my own team close to the target and closer than me,
    // and no enemy is closer and this other member is not in combat and
    // has the same target, then choose a new target.
    float fToTarget = GetDistanceToObject( oTarget );
    int i = 1;
    int bNewTarget = FALSE;
    object oCreature = GetNearestObjectToLocation( OBJECT_TYPE_CREATURE, GetLocation( oTarget ), i );
    while (GetIsObjectValid( oCreature ))
    {
        if (GetLocation( oCreature ) == GetLocation( OBJECT_SELF ))
            break;
        if (GetDistanceBetween( oCreature, oTarget ) > fToTarget)
            break;
        if (GetDistanceBetween( oCreature, oTarget ) > 5.0)
            break;
        if (!SameTeam( oCreature ))
            break;
        if (GetIsInCombat( oCreature ))
            break;
        if (GetLocalString( oCreature, "TARGET" ) == sTarget)
        {
            bNewTarget = TRUE;
            break;
        }
        ++i;
        oCreature = GetNearestObjectToLocation( OBJECT_TYPE_CREATURE, GetLocation( oTarget ), i );
    }

    if (bNewTarget)
    {
        sTarget = GetGoodTarget();
        SetLocalString( OBJECT_SELF, "TARGET", sTarget );
        oTarget = GetObjectByTag( sTarget );
        if (!GetIsObjectValid( oTarget ))
            return;
        fToTarget = GetDistanceToObject( oTarget );
    }

    if (fToTarget > 0.5)
        ActionMoveToLocation( GetLocation( oTarget ), TRUE );

    return;
}

// Called when the NPC is spawned.
void T2_Spawn()
{
    string sTarget = GetGoodTarget();
    SetLocalString( OBJECT_SELF, "TARGET", sTarget );
    ActionMoveToLocation( GetLocation( GetObjectByTag( sTarget ) ), TRUE );
}

// This function is called when certain events take place, after the standard
// NWN handling of these events has been performed.
void T2_UserDefined( int Event )
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
            T2_HeartBeat();
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
            break;

        // When the NPC has just been spawned.
        case EVENT_SPAWN:
            T2_Spawn();
            break;
    }

    return;
}

// Called when the fight starts, just before the initial spawning.
void T2_Initialize( string sColor )
{
    SetTeamName( sColor, "Default-" + GetStringLowerCase( sColor ) );
}
