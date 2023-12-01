#include "NW_I0_GENERIC"
#include "our_constants"

/////////////////
// Function to get the number of enemies around a specific altar

// Setting colors to identify enemies\allies
string sOurColor = MyColor(OBJECT_SELF);
string sOppColor = OpponentColor(OBJECT_SELF);

int GetNumEnemiesAroundAltar(object oAltar)
{
    // Define the detection radius here
    float detectionRadius = 6.0;

    // Get all creatures in the game
    object oCreature = GetFirstObjectInArea();
    int numEnemies = 0;

    // Iterate through all creatures
    while (GetIsObjectValid(oCreature))
    {
        // Check if the object is a creature and an enemy
        if (GetObjectType(oCreature) == OBJECT_TYPE_CREATURE && !SameTeam(oCreature))
        {
            // Check the distance between the creature and the altar
            float distanceToAltar = GetDistanceBetween(oCreature, oAltar);

            // If the distance is within the detection radius, increment the enemy count
            if (distanceToAltar <= detectionRadius)
            {
                numEnemies++;

                // Add extra points if the enemy is a master
                if (GetTag(oCreature) == "NPC_RED_4")
                {
                    numEnemies += 3;
                }

                // Add extra points if the enemy is a fighter\amazon
                if (GetTag(oCreature) == "NPC_RED_3")
                {
                    numEnemies += 2;
                }

                if (GetTag(oCreature) == "NPC_RED_5")
                {
                    numEnemies += 2;
                }
            }
        }

        // Move to the next object in the area
        oCreature = GetNextObjectInArea();
    }

    // Return the number of enemies
    return numEnemies;
}


//// Chooses the best altar for roam team
string GetBestAltar()

{
    // Define the altar tags
    string sAltar1 = "WP_ALTAR_" + sOppColor + "_1";
    string sAltar2 = "WP_ALTAR_" + sOppColor + "_2";

    // Get the altars
    object oAltar1 = GetObjectByTag(sAltar1);
    object oAltar2 = GetObjectByTag(sAltar2);

    // Calculate the scores for each altar
    int score1 = GetNumEnemiesAroundAltar(oAltar1);
    int score2 = GetNumEnemiesAroundAltar(oAltar2);;

    // Check for altars with zero enemies
    if (score1 == 0) return sAltar1;
    if (score2 == 0) return sAltar2;

    // If all altars have enemies, return an empty string
    return "WP_DOUBLER";
}


// Separate team, which consists of master
// His goal is to identify empty enemy altars and capture them
void T1_RoamTeam()
{
    string sTarget = GetRandomTarget();
    string sOurColor = MyColor(OBJECT_SELF);

    if (IsMaster())
    {
        object oMaster = GetObjectByTag("NPC_" + sOurColor + "_4");
        if (SameTeam(oMaster)) // Check if the master is from our team
        {
        sTarget = GetBestAltar();
        SpeakString("Moving to altar: " + sTarget, TALKVOLUME_SHOUT);
        SetLocalString(oMaster, "TARGET", sTarget);
        ActionMoveToLocation(GetLocation(GetObjectByTag(sTarget)), TRUE);
        }
     }

}





/////////////////////////////
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

    // If team member occupies altar, make it not a preferred altar
    int friendlyAltarControl = ClaimerOf( sAltar ) == MyColor();
    if (friendlyAltarControl == TRUE) {
        return -999.9;
    }

    // check if altar is occupied by no one and if that's the case, make that the preferred altar
    int enemyAltarControl = ClaimerOf( sAltar ) != MyColor();
    if (friendlyAltarControl == FALSE && enemyAltarControl == FALSE) {
        return 999.9;
    }


    object oAltar = GetObjectByTag( sAltar );
    int numEnemies = GetNumEnemiesAroundAltar(oAltar);

    // distance and number of enemies at an altar affect the score
    float score = 0.0 - GetDistanceBetween(OBJECT_SELF, oAltar) - 20.0 * numEnemies;

    return score;
}

string GetGoodTarget()
{
    // The next line moves to the spawn location of the similar opponent
    // ActionMoveToLocation( GetLocation( GetObjectByTag( "WP_" + OpponentColor( OBJECT_SELF ) + "_" + IntToString( GetLocalInt( OBJECT_SELF, "INDEX" ) ) ) ), TRUE );

    // important locations defined with string variables
    string sDoubler = WpDoubler();
    string sClosestLeft = WpClosestAltarLeft();
    string sClosetsRight = WpClosestAltarRight();
    string sFurthestLeft = WpFurthestAltarLeft();
    string sFurthestRight = WpFurthestAltarRight();

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
void T1_DetermineCombatRound( object oIntruder = OBJECT_INVALID, int nAI_Difficulty = 10 )
{
    DetermineCombatRound( oIntruder, nAI_Difficulty );
}

// Called every heartbeat (i.e., every six seconds).
void T1_HeartBeat()
{
    T1_RoamTeam();


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
void T1_Spawn()
{
    string sTarget = GetGoodTarget();
    SetLocalString( OBJECT_SELF, "TARGET", sTarget );
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
    SetTeamName( sColor, "Team 10 -" + GetStringLowerCase( sColor ) );
}
