"""Regenerates Data/<Game>/Trainer-Spells-<Game>.lua from a source folder of trainer data (one <Class>.lua per class).

Usage (from anywhere): python tools/gen_trainer_data.py <source dir> <Game> [SpellName.csv]
<Game> is the flavor folder to write (Vanilla, Discovery, TBC, Camelot, ...). SpellName.csv is a wago.tools export of
that client's build, used for each row's trailing name; without it the rows carry no name. Then /reload.
"""
import csv
import os
import re
import sys

here = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if len(sys.argv) < 3:
    sys.exit(__doc__)
src, game = sys.argv[1], sys.argv[2]
names = {}
if len(sys.argv) > 3:
    with open(sys.argv[3], encoding="utf-8") as f:
        names = {int(row["ID"]): row["Name_lang"] for row in csv.DictReader(f)}
out_dir = os.path.join(here, "Data", game)
classes = ["Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue", "Shaman", "Warlock", "Warrior"]
entry_re = re.compile(r"\{id = (\d+)((?:[^{}]|\{[^{}]*\})*)\}")
level_re = re.compile(r"\[(\d+)\] = \{")
guards = {
    "Vanilla": "if ns.IS_DISCOVERY then\n\treturn\nend\n\n",
    "Discovery": "if not ns.IS_DISCOVERY then\n\treturn\nend\n\n",
}
lines = [
    "local _, ns = ...\n\n",
    guards.get(game, ""),
    "-- [classToken] = { { level, id, requires = { spellId }, faction, race = raceId, talent }, ... }, sorted by level\n",
    "ns.TRAINER_SPELLS = {\n",
]
for cls in classes:
    text = open(os.path.join(src, cls + ".lua"), encoding="utf-8").read()
    text = text[text.index("wt.SpellsByLevel") :]
    levels = [(m.start(), int(m.group(1))) for m in level_re.finditer(text)]
    rows, dropped, talents = [], 0, set()
    for m in entry_re.finditer(text):
        level = max(l for pos, l in levels if pos < m.start())
        rest = m.group(2)
        talent = re.search(r"requiredTalentId = (\d+)", rest)
        if talent:
            # A talent's higher ranks come from the trainer; rank 1 (the talent itself) isn't listed, so add it
            # in their place, at the level of its first trainer rank (the talent's own level isn't in the data).
            dropped += 1
            if talent.group(1) not in talents:
                talents.add(talent.group(1))
                rows.append((level, int(talent.group(1)), f"level = {level}, id = {talent.group(1)}, talent = true"))
            continue
        fields = [f"level = {level}", f"id = {m.group(1)}"]
        req = re.search(r"requiredIds = \{([^}]*)\}", rest)
        if req:
            fields.append("requires = { " + req.group(1).strip() + " }")
        fac = re.search(r'faction = "(\w+)"', rest)
        if fac:
            fields.append(f'faction = "{fac.group(1)}"')
        race = re.search(r"race = (\d+)", rest)
        if race:
            fields.append(f"race = {race.group(1)}")
        unknown = set(re.findall(r"(\w+) =", rest)) - {"cost", "requiredIds", "faction", "race"}
        assert not unknown, (cls, m.group(0))
        rows.append((level, int(m.group(1)), ", ".join(fields)))
    rows.sort(key=lambda r: r[0])  # stable: keeps file order within a level
    lines.append(f"\t{cls.upper()} = {{\n")
    for _, spell_id, fields in rows:
        name = names.get(spell_id)
        lines.append(f"\t\t{{ {fields} }}," + (f" -- {name}" if name else "") + "\n")
    lines.append("\t},\n")
    print(cls, len(rows), "kept,", dropped, "talent ranks dropped,", len(talents), "talents added")
lines.append("}\n")
os.makedirs(out_dir, exist_ok=True)
with open(os.path.join(out_dir, f"Trainer-Spells-{game}.lua"), "w", encoding="utf-8", newline="\n") as f:
    f.write("".join(lines))
