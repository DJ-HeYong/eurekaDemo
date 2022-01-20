--==============================================================================--
-- 角色额外操作选项:结婚的全局方法 --
--==============================================================================--

CharacterExOp_marry = {}



function CharacterExOp_marry:is_can_marry(query_character, query_faction_leader)
    if ((query_character:is_male() and query_faction_leader:is_male()) or
            (not query_character:is_male() and not query_faction_leader:is_male())
    ) then
        --不可搞基，不可百合
        ModLog("FactionEffectBundleAwarded--执行, 【纳妻妾】，同性焉能结婚，则返回不做操作");
        return false
    end
    --如果此人已经是主公的伴侣，则返回不做操作
    if (query_character:family_member():has_spouse() and
            query_character:family_member():spouse():character() == query_faction_leader) then
        ModLog("FactionEffectBundleAwarded--执行, 【纳妻妾】，此人已经是主公的伴侣，则返回不做操作");
        return false
    end
    return true;
end


--纳妻（新人直接成为正室）
---注意（必读）： 不知道为何使用incident事件无法成功，所以换成了dilemma事件---
---注意（必读）： dilemma之所以可以使用Payload Key: MARRIAGE来实现多个伴侣，我认为是CA的bug！正因为有这个bug，才实现了纳妻！
---      ---------------- cdir_events_dilemma_payloads_tables -----------------
---      4444002    dilemmas_纳妻    SECOND    MARRIAGE    MARRIAGE_TARGET[target_character_1]    target_character_2
---      这条dilemma的数据代表，target_character_1 将和 target_character_2 结婚，两者的伴侣互相设置为彼此，但是不会首先判断他们之前是否拥有伴侣，不会先执行离婚。
---      举例，当吕布本来有“严夫人”时，吕布执行纳妻 “貂蝉”，就会形成 吕布 和 貂蝉 是一对，严夫人的丈夫是吕布，吕布的妻子却是 “貂蝉”了。这也是正和家谱里面的显示对应！！！
--先注释掉新人离婚，操作放在cdir_events_incident_payloads_tables或cdir_events_dilemma_payloads_tables中执行
--[[
--如果此人已经结婚,且ta的伴侣不是主公，先离婚
if (query_character:family_member():has_spouse() and
        query_character:family_member():spouse():character() ~= query_faction_leader
) then
    ModLog("FactionEffectBundleAwarded--执行, 【纳妻】，此人的伴侣不是主公，先离婚");
    modify_character:family_member():divorce_spouse()
end
]]--
function CharacterExOp_marry:marry_wife(query_character, modify_character, query_faction, modify_faction)
    local query_faction_leader = query_faction:faction_leader();
    if (not is_can_marry(query_character, query_faction_leader)) then
        return ;
    end
    --结婚：通过dilemma事件类型，来触发两个角色的结婚
    --无论主公现在是否有伴侣，执行纳妻，新人直接成为正室
    --DIVORCE_TARGET[target_character_1];MARRIAGE_TARGET[target_character_1]
    --新妾离婚--->新妾和主公结婚，保证新妾变为正室
    local dilemma_marry = cm:modify_model():create_dilemma("dilemmas_纳妻");
    dilemma_marry:add_character_target("target_character_1", query_character);
    dilemma_marry:add_character_target("target_character_2", query_faction_leader);
    dilemma_marry:add_faction_target("target_faction_1", query_faction);
    dilemma_marry:trigger(modify_faction, true);

    --扣除国库（结婚肯定要花钱啊）
    modify_faction:decrease_treasury(300)
    ModLog("FactionEffectBundleAwarded--执行, 【纳妻】，国库减少300");
end

--纳妾（新人成为侧室）
function CharacterExOp_marry:marry_concubine(query_character, modify_character, query_faction, modify_faction)
    local query_faction_leader = query_faction:faction_leader();
    if (not is_can_marry(query_character, query_faction_leader)) then
        return ;
    end
    --结婚：通过dilemma事件类型，来触发两个角色的结婚
    if (not query_faction_leader:family_member():has_spouse()) then
        --主公没有伴侣，执行纳妻
        --DIVORCE_TARGET[target_character_1];MARRIAGE_TARGET[target_character_1]
        --新妾离婚--->新妾和主公结婚，保证新妾变为正室
        local dilemma_marry = cm:modify_model():create_dilemma("dilemmas_纳妻");
        dilemma_marry:add_character_target("target_character_1", query_character);
        dilemma_marry:add_character_target("target_character_2", query_faction_leader);
        dilemma_marry:add_faction_target("target_faction_1", query_faction);
        dilemma_marry:trigger(modify_faction, true);
    else
        --主公有伴侣，执行纳妾
        --DIVORCE_TARGET[target_character_1];MARRIAGE_TARGET[target_character_1];MARRIAGE_TARGET[target_character_3]
        --新妾离婚--->新妾和主公结婚--->原配再次和主公结婚，保证原配仍然是正室
        local dilemma_marry = cm:modify_model():create_dilemma("dilemmas_纳妾");
        dilemma_marry:add_character_target("target_character_1", query_character);--新妾
        dilemma_marry:add_character_target("target_character_2", query_faction_leader);--主公
        dilemma_marry:add_character_target("target_character_3", query_faction_leader:family_member():spouse():character());--原配
        dilemma_marry:add_faction_target("target_faction_1", query_faction);
        dilemma_marry:trigger(modify_faction, true);
    end
    --扣除国库（结婚肯定要花钱啊）
    modify_faction:decrease_treasury(100)
    ModLog("FactionEffectBundleAwarded--执行, 【纳妾】，国库减少100");
end

