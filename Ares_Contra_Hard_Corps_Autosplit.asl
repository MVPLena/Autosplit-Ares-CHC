state("ares")
{
    ushort reset_flag : "ares.exe", 0x61A2AE0;
    byte   start_flag : "ares.exe", 0x61AA80C;

    byte val1 : "ares.exe", 0x61C55F6;
    byte val2 : "ares.exe", 0x61C564E;
    byte val3 : "ares.exe", 0x61C56A6;
    byte val4 : "ares.exe", 0x61C56FE;

    byte block1 : "ares.exe", 0x61A8BE3;
    byte block2 : "ares.exe", 0x61AA8B5;

    byte fast1 : "ares.exe", 0x61A1A42;
    byte fast2 : "ares.exe", 0x61AD9F2;

    ushort phase_code : "ares.exe", 0x61A4BF4;
    byte stage_flag : "ares.exe", 0x61ACD24;
}

init
{
    vars.split_ready = false;
    vars.block_split = false;
    vars.fast_forward = false;

    vars.special_split_triggered = false;

    vars.once_196_val3 = false;
    vars.once_218_val3 = false;

    vars.once_17_stage = false;
}

update
{
    vars.split_ready =
        current.val1 == 2 &&
        current.val2 == 3 &&
        current.val3 == 3 &&
        current.val4 == 3;

    vars.block_split =
        current.block1 == 196 &&
        current.block2 == 170 &&
        vars.split_ready;

    vars.fast_forward =
        current.block1 == 196 &&
        current.block2 == 170 &&
        current.fast1 == 76 &&
        current.fast2 == 76;

    if (current.block1 != 129)
        vars.special_split_triggered = false;

    if (!(current.block1 == 196 && current.val3 == 2))
        vars.once_196_val3 = false;

    if (!(current.block2 == 218 && current.val3 == 2))
        vars.once_218_val3 = false;

    if (!(current.block1 == 17 &&
          current.stage_flag == 6 &&
          current.phase_code == 52445))
    {
        vars.once_17_stage = false;
    }
}

start
{
    return current.start_flag == 1 && old.start_flag != 1;
}

split
{
    if (!vars.once_218_val3 &&
        current.block2 == 218 &&
        current.val3 == 2)
    {
        vars.once_218_val3 = true;
        return true;
    }

    if (!vars.once_196_val3 &&
        current.block1 == 196 &&
        current.val3 == 2)
    {
        vars.once_196_val3 = true;
        return true;
    }

    // block1=17 + stage_flag (2→6) + phase_code=52445
    if (!vars.once_17_stage &&
        current.block1 == 17 &&
        old.stage_flag == 2 &&
        current.stage_flag == 6 &&
        current.phase_code == 52445)
    {
        vars.once_17_stage = true;
        return true;
    }

    if (old.block1 == 129 && current.block1 == 68 && !vars.special_split_triggered)
    {
        vars.special_split_triggered = true;
        return true;
    }

    if (vars.split_ready &&
        current.block2 == 218)
    {
        return false;
    }

    if (vars.split_ready &&
        !vars.block_split &&
        current.phase_code != 3603 &&
        !(old.val1 == 2 && old.val2 == 3 && old.val3 == 3 && old.val4 == 3))
    {
        return true;
    }

    return false;
}

reset
{
    return current.reset_flag == 1 && old.reset_flag != 1;
}
