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
    { "effect_bundle_纳妾character", "effect_bundle_纳妾faction" },
    { "effect_bundle_结拜character", "effect_bundle_结拜faction" }
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

--纳妾（主公可男可女）
local function marry(query_character, modify_character, query_faction, modify_faction)
    local query_faction_leader = query_faction:faction_leader();
    if ((query_character:is_male() and query_faction_leader:is_male()) or
            (not query_character:is_male() and not query_faction_leader:is_male())
    ) then
        --不可搞基，不可百合
        ModLog("FactionEffectBundleAwarded--执行, 【纳妾】，同性焉能结婚，则返回不做操作");
        return
    end
    --如果此人已经是主公的伴侣，则返回不做操作
    if (query_character:family_member():has_spouse() and
            query_character:family_member():spouse():character() == query_faction_leader) then
        ModLog("FactionEffectBundleAwarded--执行, 【纳妾】，此人已经是主公的伴侣，则返回不做操作");
        return
    end

    --先注释掉离婚，离婚操作放在cdir_events_incident_payloads_tables或cdir_events_dilemma_payloads_tables中执行
    --[[
    --如果此人已经结婚,且ta的伴侣不是主公，先离婚
    if (query_character:family_member():has_spouse() and
            query_character:family_member():spouse():character() ~= query_faction_leader
    ) then
        ModLog("FactionEffectBundleAwarded--执行, 【纳妾】，此人的伴侣不是主公，先离婚");
        modify_character:family_member():divorce_spouse()
    end
    ]]--

    --结婚：通过incident事件类型，来触发两个角色的结婚
    -- ModLog("FactionEffectBundleAwarded--执行, 【纳妾】，通过incident事件类型，来触发两个角色的结婚");
    -- local incident_marry = cm:modify_model():create_incident("incident_纳妾")
    -- incident_marry:add_character_target("target_character_1", query_faction_leader);
    -- incident_marry:add_character_target("target_character_2", query_character);
    -- incident_marry:add_faction_target("target_faction_1", query_faction);
    -- incident_marry:trigger(modify_faction, true);

    ---注意（必读）： 不知道为何使用incident事件无法成功，所以换成了dilemma事件，但是pack中incident相关的table我也没删掉，先留着吧，反正不影响---
    ---注意（必读）： dilemma之所以可以使用Payload Key: MARRIAGE来实现多个伴侣，我认为是CA的bug！正因为有这个bug，才实现了纳妾！
    ---      ---------------- cdir_events_dilemma_payloads_tables -----------------
    ---      4444002    dilemmas_纳妾    SECOND    MARRIAGE    MARRIAGE_TARGET[target_character_1]    target_character_2
    ---      这条dilemma的数据代表，target_character_1 将和 target_character_2 结婚，两者的伴侣互相设置为彼此，但是不会首先判断他们之前是否拥有伴侣，不会先执行离婚。
    ---      举例，当吕布本来有“严夫人”时，吕布执行纳妾 “貂蝉”，就会形成 吕布 和 貂蝉 是一对，严夫人的丈夫是吕布，吕布的妻子却是 “貂蝉”了。这也是正和家谱里面的显示对应！！！

    --结婚：通过dilemma事件类型，来触发两个角色的结婚
    ModLog("FactionEffectBundleAwarded--执行, 【纳妾】，通过dilemma事件类型，来触发两个角色的结婚");
    local dilemma_marry = cm:modify_model():create_dilemma("dilemmas_纳妾");
    dilemma_marry:add_character_target("target_character_1", query_character);
    dilemma_marry:add_character_target("target_character_2", query_faction_leader);
    dilemma_marry:add_faction_target("target_faction_1", query_faction);
    dilemma_marry:trigger(modify_faction, true);

    --扣除国库（结婚肯定要花钱啊）
    modify_faction:decrease_treasury(100)
    ModLog("FactionEffectBundleAwarded--执行, 【纳妾】，国库减少100");
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
                        elseif (effect_bundle_key_character == "effect_bundle_纳妾character") then
                            marry(query_character, modify_character, query_faction, modify_faction)
                        elseif (effect_bundle_key_character == "effect_bundle_结拜character") then
                            brother(query_character, modify_character, query_faction, modify_faction)
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