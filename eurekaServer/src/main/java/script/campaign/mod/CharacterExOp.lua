--==============================================================================--
-- Script --
-- 角色额外操作选项 --
-- author:我有一个学妹 --
-- steam个人空间: https://steamcommunity.com/id/hyhyof/
-- 若遇问题，欢迎到我的steam个人空间留言，或者在创意工坊留言 --
--==============================================================================--


--==============================================================================--
-- 公共的变量 --
--==============================================================================--

local listen_name = "listen_character_ex_op_byHy"

local effect_bundle_key_list = {
    { "effect_bundle_斩首character", "effect_bundle_斩首faction" },
    { "effect_bundle_纳妻character", "effect_bundle_纳妻faction" },
    { "effect_bundle_纳妾character", "effect_bundle_纳妾faction" },
    { "effect_bundle_结拜character", "effect_bundle_结拜faction" },
    { "effect_bundle_巩固忠诚character", "effect_bundle_巩固忠诚faction" }
}

local function is_contain_effect_bundle_key_faction(effect_bundle_key)
    for i = 1, #effect_bundle_key_list do
        if (effect_bundle_key_list[i][2] == effect_bundle_key) then
            return true;
        end
    end
    return false;
end

local function get_effect_bundle_key_character(effect_bundle_key)
    for i = 1, #effect_bundle_key_list do
        if (effect_bundle_key_list[i][2] == effect_bundle_key) then
            return effect_bundle_key_list[i][1];
        end
    end
    return nil;
end


--==============================================================================--
-- 执行方法 --
--==============================================================================--

--斩首
local function kill(modify_character, modify_faction)
    modify_character:kill_character(true)
    modify_faction:increase_treasury(1000)
    ModLog("FactionEffectBundleAwarded--执行, 【斩首】，国库增加1000");
end


--结拜
local function brother(query_character, modify_character, query_faction, modify_faction)
    if (query_character:family_member():is_in_faction_leaders_family()) then
        ModLog("FactionEffectBundleAwarded--执行, 【结拜】，此人已经在主公的family之中，则返回不做操作");
        return
    end
    --添加义亲的关系
    local query_faction_leader = query_faction:faction_leader();
    modify_character:apply_relationship_trigger_set(query_faction_leader, "3k_main_relationship_trigger_set_startpos_battle_own_victory_heroic")
    modify_character:apply_relationship_trigger_set(query_faction_leader, "3k_main_relationship_trigger_set_event_positive_generic_extreme")
    modify_character:apply_relationship_trigger_set(query_faction_leader, "3k_dlc05_relationship_trigger_set_startpos_romance")
    --添加满意度
    modify_character:add_loyalty_effect("data_random_events_positive_large")--满意度：吉事 20，15回合
    modify_character:add_loyalty_effect("past_experience_fondness")--满意度：派系喜爱 15，无限回合
    --loyalty_effect：married_daughter 与主公联姻 = 满意度：派系喜爱 25，50回合

    ModLog("FactionEffectBundleAwarded--执行, 【结拜】，添加义亲的关系");
    --若主公有父亲，则将结拜的对象设置为father的孩子，以便可以展示在家谱上
    if (query_faction_leader:family_member():has_father()) then
        local query_faction_leader_father = query_faction_leader:family_member():father():character();
        local modify_faction_leader_father = cm:modify_character(query_faction_leader_father:cqi())
        modify_character:make_child_of(modify_faction_leader_father);
        ModLog("FactionEffectBundleAwarded--执行, 【结拜】，主公有父亲，将结拜的对象设置为father的孩子，以便可以展示在家谱上");
    end
    --扣除国库
    modify_faction:decrease_treasury(100)
    ModLog("FactionEffectBundleAwarded--执行, 【结拜】，国库减少100");
end


--巩固忠诚
local function solidify_loyalty(modify_character, modify_faction)
    modify_character:add_loyalty_effect("past_experience_fondness")--满意度：派系喜爱 15，无限回合
    modify_character:add_loyalty_effect("presented_gift")--满意度：礼尚往来 40，10回合
    --扣除国库
    modify_faction:decrease_treasury(300)
    ModLog("FactionEffectBundleAwarded--执行, 【巩固忠诚】，国库减少300");
end

--==============================================================================--
-- 监听函数 --
--==============================================================================--
local function characterExOp_byHy()
    core:add_listener(
            listen_name,
            "FactionEffectBundleAwarded",
            function(context)
                return is_contain_effect_bundle_key_faction(context:effect_bundle_key())
            end,
            function(context)
                ModLog("------------分割线------------------- ");
                ModLog("------------分割线------------------- ");
                ModLog("------------分割线------------------- ");
                --为什么使用FactionEffectBundleAwarded？？？ 因为没找到其他更好的办法！
                --effect_bundle_key 只是用来给势力，和武将添加buff的，为了配合"FactionEffectBundleAwarded"事件监听，从而知道鼠标点击的按钮对应哪个武将。
                --为了不影响下一次按钮的点击，所以我们每次都要清除faction和character的effect_bundle_key

                local effect_bundle_key_faction = context:effect_bundle_key()
                local effect_bundle_key_character = get_effect_bundle_key_character(effect_bundle_key_faction)
                local query_faction = context:faction()
                local modify_faction = cm:modify_faction(query_faction)
                --先移除势力的effect_bundle，每次必须移除
                modify_faction:remove_effect_bundle(effect_bundle_key_faction)
                local character_list = query_faction:character_list()
                for i = 0, character_list:num_items() - 1 do
                    local query_character = character_list:item_at(i)
                    if ((not query_character:is_dead()) and query_character:has_effect_bundle(effect_bundle_key_character)) then
                        local character_template_key = query_character:generation_template_key();
                        local cqi = query_character:cqi();
                        local modify_character = cm:modify_character(cqi)
                        --先移除武将身上的effect_bundle，每次必须移除
                        modify_character:remove_effect_bundle(effect_bundle_key_character);
                        ModLog("FactionEffectBundleAwarded--执行, 目标人物: " .. character_template_key);
                        --根据类型，调用不同的方法
                        if (effect_bundle_key_character == "effect_bundle_斩首character") then
                            kill(modify_character, modify_faction)
                        elseif (effect_bundle_key_character == "effect_bundle_纳妻character") then
                            CharacterExOp_marry_byHy:marry_wife(query_character, modify_character, query_faction, modify_faction)
                        elseif (effect_bundle_key_character == "effect_bundle_纳妾character") then
                            CharacterExOp_marry_byHy:marry_concubine(query_character, modify_character, query_faction, modify_faction)
                        elseif (effect_bundle_key_character == "effect_bundle_结拜character") then
                            brother(query_character, modify_character, query_faction, modify_faction)
                        elseif (effect_bundle_key_character == "effect_bundle_巩固忠诚character") then
                            solidify_loyalty(modify_character, modify_faction)
                        end
                        --由于上面character每次都会移除effect_bundle，所以此处只需要检测到一个符合条件的character即可，然后break跳出循环
                        break ;
                    end
                end
            end,
            true
    )
end

cm:add_first_tick_callback(function()
    characterExOp_byHy()
end)