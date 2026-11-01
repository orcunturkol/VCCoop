// Course sur Maj gauche (CourseShift=1, defaut) : a pied, Maj gauche maintenue appuie sur le bouton "sprint" de la
// manette (croix, Pads[0].PCTempJoyState +0x20, comme les autotests). Les touches de l'utilisateur ne changent pas :
// par defaut le jeu ne met Maj gauche que sur le klaxon (en vehicule), rien a pied.
#include "util.h"
#include "vccoop.h"
#include "game.h"
#include "panel.h"

using namespace game;

bool g_testShiftHeld;   // autotest "maj" : Maj gauche simulee (instances de test sans le focus)

void ShiftSprintFrame()
{
    static bool pressing;
    short &cross = *(short *)((uint8_t *)0x7DBCB0 + 0x96 + 0x20);
    void *me = FindPlayerPed();
    bool held = g_testShiftHeld || (GameHasFocus() && !PanelCapturesKeys() && (GetAsyncKeyState(VK_LSHIFT) & 0x8000));
    bool want = g_cfg.shiftSprint && GameState() == GS_PLAYING && me && !InVehicle(me) && !MenuActive() && held;
    if (want) { cross = 255; pressing = true; }
    else if (pressing) { cross = 0; pressing = false; }
}
