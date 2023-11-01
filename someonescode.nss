// code from a computer
// error free
// poorer performance than baseline code

fhealing#include "NW_I0_GENERIC"
#include "our_constants"

// Move character to the start position we assigned them to.
void T2_MoveToAssignedPosition()
{
    string sTarget = GetRandomTarget();
    string sOurColor = MyColor(OBJECT_SELF);
    if (IsWizardLeft())
    {
        sTarget = WpClosestAltarLeft();
    }
    if (IsWizardRight())
    {
        sTarget = WpClosestAltarRight();
    }
    if (IsClericRight())
    {
        sTarget = "WP_ALTAR_" + sOurColor + "_1C";
    }
    if (IsClericLeft())
    {
        sTarget = "WP_ALTAR_" + sOurColor + "_2C";
    }
    if (IsFighterRight())
    {
        sTarget = "WP_CENTRE_" + sOurColor + "_1";
    }
    if (IsFighterLeft())
    {
        sTarget = WpDoubler();
    }
    if (IsMaster())
    {
        sTarget = "WP_CENTRE_" + sOurColor + "_3";
    }
    SetLocalString(OBJECT_SELF, "TARGET", sTarget);
    ActionMoveToLocation(GetLocation(GetObjectByTag(sTarget)), TRUE);
}

int T2_CheckEnemyPositionsLeft()
{
        string sCaL = WpFurthestAltarLeft();
        object oCaL = GetObjectByTag(sCaL);
        int nEnemyL = CheckEnemyGroupingOnTarget(oCaL, 20.0);
        return nEnemyL;
}

int T2_CheckEnemyPositionsRight()
{
        string sCaR = WpFurthestAltarRight();
        object oCaR = GetObjectByTag(sCaR);
        int nEnemyR = CheckEnemyGroupingOnTarget(oCaR, 20.0);
        return nEnemyR;
}

int T2_CheckEnemyPositionsLeftOwn()
{
        string sCaL = WpClosestAltarLeft();
        object oCaL = GetObjectByTag(sCaL);
        int nEnemyL = CheckEnemyGroupingOnTarget(oCaL, 20.0);
        return nEnemyL;
}

int T2_CheckEnemyPositionsRightOwn()
{
        string sCaR = WpClosestAltarRight();
        object oCaR = GetObjectByTag(sCaR);
        int nEnemyR = CheckEnemyGroupingOnTarget(oCaR, 20.0);
        return nEnemyR;
}

int getHeartBeatCounter()
{
    object oDoubler = GetObjectByTag(WpDoubler());
    return GetLocalInt(oDoubler, "heart-beat-counter");
}


void updateHeartBeatCounter()
{
   int currentCounter = getHeartBeatCounter();
   object oDoubler = GetObjectByTag(WpDoubler());
   SetLocalInt(oDoubler, "heart-beat-counter", currentCounter + 1);
}

// possible addition = only move to enemy area fighter and cleric together, not alone

void T2_MoveToEnemyAltars()
{

    string sOurColor = MyColor(OBJECT_SELF);
    string sOppColor = OpponentColor(OBJECT_SELF);

    if (IsMaster())
    {
        SpeakString("I'm doing stuff!! ", TALKVOLUME_SHOUT);
        string sWp =  WpDoubler();
        object oWp = GetObjectByTag(sWp);
        if (!GetIsObjectValid(oWp))
            return;
        object oMaster = GetObjectByTag("NPC_" + sOurColor + "_6");
        string sTargetM = "WP_CENTRE_" + sOurColor + "_3";
        object oTargetM = GetObjectByTag(sTargetM);
        SetLocalString(oMaster, "TARGET", sTargetM);
        ActionMoveToLocation(GetLocation(oTargetM), TRUE);
    }

    if (getHeartBeatCounter() % 2 == 0)
    {
        int nEnemyR = T2_CheckEnemyPositionsRight();
        int nEnemyL = T2_CheckEnemyPositionsLeft();

        if (nEnemyL < 1 | nEnemyR < 1) // only attack enemy altars if there are no enemies there
        {
           if (nEnemyL < nEnemyR) // preferences to go to left enemy altar
           {
              if (IsWizardLeft())
                {
                    object oWizardLeft = GetObjectByTag("NPC_" + sOurColor + "_7");
                    string sTargetWL = "WP_ALTAR_" + sOurColor + "2";
                    SetLocalString(oWizardLeft, "TARGET", sTargetWL);
                    ActionMoveToLocation(GetLocation(GetObjectByTag(sTargetWL)), TRUE);
                }

                if (IsClericLeft())
                {
                    object oClericLeft = GetObjectByTag("NPC_" + sOurColor + "_6");
                    string sTargetCL = "WP_ALTAR_"+ sOppColor+ "_1";
                    SetLocalString(oClericLeft, "TARGET", sTargetCL);
                    ActionMoveToLocation(GetLocation(GetObjectByTag(sTargetCL)), TRUE);
                }

                if (IsFighterLeft())
                {
                    object oFighterLeft = GetObjectByTag("NPC_" + sOurColor + "_5");
                    string sTargetFL = "WP_CENTRE_"+sOppColor+"_1A";
                    SetLocalString(oFighterLeft, "TARGET", sTargetFL);
                    ActionMoveToLocation(GetLocation(GetObjectByTag(sTargetFL)), TRUE);
                    // fighter left goes away from doubler, so send fighter right to defend doubler
                    if (IsFighterRight())
                    {
                        object oFighterRight = GetObjectByTag("NPC_" + sOurColor + "_3");
                        string sTargetFRToDoubler = WpDoubler();
                        SetLocalString(oFighterRight, "TARGET", sTargetFRToDoubler);
                        ActionMoveToLocation(GetLocation(GetObjectByTag(sTargetFRToDoubler)), TRUE);
                    }
                 }
            SpeakString("Attack left enemy altar!", TALKVOLUME_SHOUT);
            }
           }

            else // if right enemy altar is prefered go to that altar
            {
                if (nEnemyR < 1) // but still only go if there are no enemies
                {
                    if (IsWizardRight())
                    {
                        object oWizardRight = GetObjectByTag("NPC_" + sOurColor + "_1");
                        string sTargetWR = "WP_ALTAR_" + sOurColor + "1";
                        SetLocalString(oWizardRight, "TARGET", sTargetWR);
                        ActionMoveToLocation(GetLocation(GetObjectByTag(sTargetWR)), TRUE);
                    }

                    if (IsClericRight())
                    {
                        object oClericRight = GetObjectByTag("NPC_" + sOurColor + "_2");
                        string sTargetCR = "WP_ALTAR_"+sOppColor+"_2";
                        SetLocalString(oClericRight, "TARGET", sTargetCR);
                        ActionMoveToLocation(GetLocation(GetObjectByTag(sTargetCR)), TRUE);
                    }

                    if (IsFighterRight())
                    {
                        object oFighterRight = GetObjectByTag("NPC_" + sOurColor + "_3");
                        string sTargetFR = "WP_CENTRE_"+sOppColor+"_2A";
                        SetLocalString(oFighterRight, "TARGET", sTargetFR);
                        ActionMoveToLocation(GetLocation(GetObjectByTag(sTargetFR)), TRUE);
                    }
            SpeakString("Attack right enemy altar!", TALKVOLUME_SHOUT);
            }

        }
    }
}

// possible addition = also check for defending doubler

int T2_MoveToFriendlyAltars()
{
    string sOurColor = MyColor(OBJECT_SELF);
    string sOppColor = OpponentColor(OBJECT_SELF);

    if (IsMaster())
    {
        SpeakString("I'm doing stuff!! ", TALKVOLUME_SHOUT);
        string sWp =  WpDoubler();
        object oWp = GetObjectByTag(sWp);
        object oMaster = GetObjectByTag("NPC_" + sOurColor + "_6");
        string sTargetM = "WP_CENTRE_" + sOurColor + "_3";
        object oTargetM = GetObjectByTag(sTargetM);
        SetLocalString(oMaster, "TARGET", sTargetM);
        ActionMoveToLocation(GetLocation(oTargetM), TRUE);
    }

    if (getHeartBeatCounter() % 2 == 0)
    { // heart
        int nEnemyR = T2_CheckEnemyPositionsRightOwn();
        int nEnemyL = T2_CheckEnemyPositionsLeftOwn();

        if (nEnemyL > 0 | nEnemyR > 0) // if no enemies on friendly altars, try to attack enemy altar or defend doubler
        { // first
           if (nEnemyL < nEnemyR && nEnemyR > 1) // if no enemy on left altar, and more than 1 enemy on right altar, defend right altar
           {  // second
                if (IsWizardLeft())  // stays on left altar to collect points
                {
                    object oWizardLeft = GetObjectByTag("NPC_" + sOurColor + "_7");
                    string sTargetWL = "WP_ALTAR_" + sOurColor + "2";
                    SetLocalString(oWizardLeft, "TARGET", sTargetWL);
                    ActionMoveToLocation(GetLocation(GetObjectByTag(sTargetWL)), TRUE);
                }

                if (IsClericLeft())
                {
                    object oClericLeft = GetObjectByTag("NPC_" + sOurColor + "_6");
                    string sTargetCL = "WP_FRONT_"+ sOurColor+ "_1";
                    SetLocalString(oClericLeft, "TARGET", sTargetCL);
                    ActionMoveToLocation(GetLocation(GetObjectByTag(sTargetCL)), TRUE);
                }

                if (IsFighterLeft())
                {
                    object oFighterLeft = GetObjectByTag("NPC_" + sOurColor + "_5");
                    string sTargetFL = "WP_FRONT_"+ sOurColor+ "_1";
                    SetLocalString(oFighterLeft, "TARGET", sTargetFL);
                    ActionMoveToLocation(GetLocation(GetObjectByTag(sTargetFL)), TRUE);
                }

                        if (IsWizardRight()) // stays on right altar to collect points
                        {
                            object oWizardRight = GetObjectByTag("NPC_" + sOurColor + "_1");
                            string sTargetWR = "WP_ALTAR_" + sOurColor + "2";
                            SetLocalString(oWizardRight, "TARGET", sTargetWR);
                            ActionMoveToLocation(GetLocation(GetObjectByTag(sTargetWR)), TRUE);
                        }
                        if (IsClericRight())
                        {
                            object oClericRight = GetObjectByTag("NPC_" + sOurColor + "_2");
                            string sTargetCR = "WP_ALTAR_" + sOurColor + "_1C";
                            SetLocalString(oClericRight, "TARGET", sTargetCR);
                            ActionMoveToLocation(GetLocation(GetObjectByTag(sTargetCR)), TRUE);
                        }

                        if (IsFighterRight())
                        {
                            object oFighterRight = GetObjectByTag("NPC_" + sOurColor + "_3");
                            string sTargetFR = "WP_FRONT_"+ sOurColor+ "_1";
                            SetLocalString(oFighterRight, "TARGET", sTargetFR);
                            ActionMoveToLocation(GetLocation(GetObjectByTag(sTargetFR)), TRUE);
                        }
            SpeakString("Defend right altar!", TALKVOLUME_SHOUT);
            return 1; // does this tactic
            }  // second

          } // first
          else
          { // else
                if (nEnemyR < 0 && nEnemyL > 1)  // if no enemy on right altar, and more than 1 enemy on left altar, defend left altar
                { // else first
                        if (IsWizardRight()) // stays on right altar to collect points
                        {
                            object oWizardRight = GetObjectByTag("NPC_" + sOurColor + "_1");
                            string sTargetWR = "WP_ALTAR_" + sOurColor + "1";
                            SetLocalString(oWizardRight, "TARGET", sTargetWR);
                            ActionMoveToLocation(GetLocation(GetObjectByTag(sTargetWR)), TRUE);
                        }
                        if (IsClericRight())
                        {
                            object oClericRight = GetObjectByTag("NPC_" + sOurColor + "_2");
                            string sTargetCR = "WP_FRONT_"+ sOurColor+ "_2";
                            SetLocalString(oClericRight, "TARGET", sTargetCR);
                            ActionMoveToLocation(GetLocation(GetObjectByTag(sTargetCR)), TRUE);
                        }

                        if (IsFighterRight())
                        {
                            object oFighterRight = GetObjectByTag("NPC_" + sOurColor + "_3");
                            string sTargetFR = "WP_FRONT_"+ sOurColor+ "_2";
                            SetLocalString(oFighterRight, "TARGET", sTargetFR);
                            ActionMoveToLocation(GetLocation(GetObjectByTag(sTargetFR)), TRUE);
                        }
                              if (IsWizardLeft())  // stays on left altar to collect points
                                {
                                    object oWizardLeft = GetObjectByTag("NPC_" + sOurColor + "_7");
                                    string sTargetWL = "WP_ALTAR_" + sOurColor + "1";
                                    SetLocalString(oWizardLeft, "TARGET", sTargetWL);
                                    ActionMoveToLocation(GetLocation(GetObjectByTag(sTargetWL)), TRUE);
                                }

                               if (IsClericLeft())
                                {
                                    object oClericLeft = GetObjectByTag("NPC_" + sOurColor + "_6");
                                    string sTargetCL = "WP_ALTAR_" + sOurColor + "_2C";
                                    SetLocalString(oClericLeft, "TARGET", sTargetCL);
                                    ActionMoveToLocation(GetLocation(GetObjectByTag(sTargetCL)), TRUE);
                                }

                               if (IsFighterLeft())
                                {
                                    object oFighterLeft = GetObjectByTag("NPC_" + sOurColor + "_5");
                                    string sTargetFL = "WP_FRONT_"+ sOurColor+ "_2";
                                    SetLocalString(oFighterLeft, "TARGET", sTargetFL);
                                    ActionMoveToLocation(GetLocation(GetObjectByTag(sTargetFL)), TRUE);
                                }

          SpeakString("Defend left altar!", TALKVOLUME_SHOUT);
          return 1; // does this tactic
          }  // else first
       } // else
    } // heart
    SpeakString("Not defending!", TALKVOLUME_SHOUT);
    return 0;
} //

void T2_DecideToAttackOrDefend()
{
    if (IsMaster())
    {
       updateHeartBeatCounter();
       SpeakString("HeartBeatCounter: " + IntToString(getHeartBeatCounter()), TALKVOLUME_SHOUT);

    }
    //if go to friendly altars
    //else go to enemy altar (if no enemies at friendly altars, and no at enemy altars)
    if (T2_MoveToFriendlyAltars() == 1)
    {
       return;
    }
    else if(T2_MoveToFriendlyAltars() == 0)
    {
        T2_MoveToEnemyAltars();
    }
    else
    {
        T2_MoveToAssignedPosition();
    }
}

// Called every time that the AI needs to take a combat decision. The default is
// a call to the NWN DetermineCombatRound.
void T2_DetermineCombatRound(object oIntruder = OBJECT_INVALID, int nAI_Difficulty = 10)
{
    if (TalentHealingSelf())
    {
        SpeakString("I am healing myself", TALKVOLUME_SHOUT);
        return;
    }
    if (IsFighterLeft())
    {
        // Get the storedlocation.
        location lPost = GetLocation(GetObjectByTag(WpDoubler()));

        // Get our location
        location lSelf = GetLocation(OBJECT_SELF);

        // Check the distance
        float fDistance = GetDistanceBetweenLocations(lPost, lSelf);
        SpeakString("distance to altar " + FloatToString(fDistance), TALKVOLUME_SHOUT);
        if (fDistance < 1.0)
        {
            return;
        }
    }
    DetermineCombatRound(oIntruder, nAI_Difficulty);
}




// Called every heartbeat (i.e., every six seconds).
void T2_HeartBeat()
{

    if (GetIsInCombat())
        return;

    string sTarget = GetLocalString(OBJECT_SELF, "TARGET");
    if (sTarget == "")
        return;

    // Here we can shout some general information for debugging purposes
    // This function creates an error, dont know why
    if (IsMaster())
    {
        SpeakString("Our score is: " + IntToString(GetScore(MyColor())), TALKVOLUME_SHOUT);
        SpeakString("Opponent score is: " + IntToString(GetScore(OpponentColor())), TALKVOLUME_SHOUT);
    }

    object oTarget = GetObjectByTag(sTarget);
    if (!GetIsObjectValid(oTarget))
        return;

    // If there is a member of my own team close to the target and closer than me,
    // and no enemy is closer and this other member is not in combat and
    // has the same target, then choose a new target.
    float fToTarget = GetDistanceToObject(oTarget);
    int i = 1;
    int bNewTarget = FALSE;
    object oCreature = GetNearestObjectToLocation(OBJECT_TYPE_CREATURE, GetLocation(oTarget), i);
    while (GetIsObjectValid(oCreature))
    {
        if (GetLocation(oCreature) == GetLocation(OBJECT_SELF))
            break;
        if (GetDistanceBetween(oCreature, oTarget) > fToTarget)
            break;
        if (GetDistanceBetween(oCreature, oTarget) > 5.0)
            break;
        if (!SameTeam(oCreature))
            break;
        if (GetIsInCombat(oCreature))
            break;
        if (GetLocalString(oCreature, "TARGET") == sTarget)
        {
            bNewTarget = TRUE;
            break;
        }
        ++i;
        oCreature = GetNearestObjectToLocation(OBJECT_TYPE_CREATURE, GetLocation(oTarget), i);
    }

    if (bNewTarget)
    {
        sTarget = GetRandomTarget();
        SetLocalString(OBJECT_SELF, "TARGET", sTarget);
        oTarget = GetObjectByTag(sTarget);
        if (!GetIsObjectValid(oTarget))
            return;
        fToTarget = GetDistanceToObject(oTarget);
    }

    T2_DecideToAttackOrDefend();

    if (fToTarget > 0.5)
         ActionMoveToLocation( GetLocation( oTarget ), TRUE );
    // T2_MoveToAssignedPosition();
    return;
}

// Called when the NPC is spawned.
void T2_Spawn()
{
    T2_MoveToAssignedPosition();
}

// This function is called when certain events take place, after the standard
// NWN handling of these events has been performed.
void T2_UserDefined(int Event)
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
void T2_Initialize(string sOurColor)
{
    SetTeamName(sOurColor, "T2-" + GetStringLowerCase(sOurColor));
    //object oPC = GetPCSpeaker();
    //SetLocalInt(oPC, "heart-beat-counter", 0);
}
