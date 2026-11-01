// Difficulte (reglage d'hote Difficulte=0/1/2, envoye a tous dans MsgWorld) : la coop rend l'histoire plus facile,
// ceci la durcit pour tout le monde.
//  - Coups des personnages (gangs, police, ennemis de mission) sur un joueur : x1,5 / x2. Applique la ou le joueur
//    subit le coup (combat.cpp : InflictDamage final et ApplyDamage des coups arrives par le reseau). Pas entre joueurs.
//  - Sante des personnages : x1,5 / x2, une fois par personnage, sur la machine qui le fait tourner (l'hote pour ses
//    passants et ennemis de mission, chaque invite pour sa population et sa police). Les copies (fantomes) suivent
//    la sante de leur proprietaire, les Tommy des autres joueurs ne sont pas touches.
#include "util.h"
#include "vccoop.h"
#include "game.h"
#include "entities.h"
#include <unordered_set>

using namespace game;

static float Factor() { return g_cfg.difficulty >= 2 ? 2.0f : g_cfg.difficulty == 1 ? 1.5f : 1.0f; }

float NpcDamageScale(void *victim, void *damager)
{
    if (g_cfg.difficulty <= 0 || !victim || victim != FindPlayerPed()) return 1.0f;
    if (!damager || !IsPedEntity(damager) || damager == victim || IsPuppet(damager)) return 1.0f;
    return Factor();
}

void DifficultyFrame()
{
    static std::unordered_set<uint32_t> done;   // personnages deja renforces (vivants au dernier passage)
    static uint32_t last;
    static int lastLevel;
    uint32_t now = GetTickCount();
    if (now - last < 500) return;
    last = now;
    if (GameState() != GS_PLAYING || g_cfg.difficulty != lastLevel) {
        // Changement de niveau en cours de partie : seuls les nouveaux personnages prennent le nouveau facteur
        lastLevel = g_cfg.difficulty;
        if (GameState() != GS_PLAYING) done.clear();
    }
    if (GameState() != GS_PLAYING) return;
    std::unordered_set<uint32_t> alive;
    void *me = FindPlayerPed();
    Pool *pool = PedPool();
    int boosted = 0;
    for (int i = 0; i < pool->size; i++) {
        if (pool->flags[i] & 0x80) continue;
        void *p = pool->objects + i * PED_POOL_ENTRY;
        if (p == me || IsPuppet(p) || IsGhostPed(p)) continue;
        uint32_t h = PedHandle(p);
        if (done.count(h)) { alive.insert(h); continue; }
        float &hp = Health(p);
        if (hp <= 0.0f || hp >= 1000.0f) continue;   // mort, ou rendu invulnerable par un script
        alive.insert(h);
        if (g_cfg.difficulty > 0) { hp *= Factor(); boosted++; }
    }
    done.swap(alive);
    if (boosted && g_cfg.logScripts) Log("difficulte : %d personnage(s) renforce(s) (x%.1f)", boosted, Factor());
    static bool said;
    if (boosted && !said) { said = true; Log("difficulte %d : personnages x%.1f (sante et degats)", g_cfg.difficulty, Factor()); }
}
