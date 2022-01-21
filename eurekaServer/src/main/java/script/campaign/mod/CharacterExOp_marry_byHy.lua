--==============================================================================--
-- 角色额外操作选项:结婚的全局方法 --
---注意（必读）： 不知道为何使用incident事件无法成功，所以换成了dilemma事件---
---注意（必读）： dilemma之所以可以使用Payload Key: MARRIAGE来实现多个伴侣，我认为是CA的bug！正因为有这个bug，才实现了纳妻！
---      ---------------- cdir_events_dilemma_payloads_tables -----------------
---      4444002    dilemmas_纳妻    SECOND    MARRIAGE    MARRIAGE_TARGET[target_character_1]    target_character_2
---      这条dilemma的数据代表，target_character_1 将和 target_character_2 结婚，两者的伴侣互相设置为彼此，但是不会首先判断他们之前是否拥有伴侣，不会先执行离婚。
---      举例，当吕布本来有“严夫人”时，吕布执行纳妻 “貂蝉”，就会形成 吕布 和 貂蝉 是一对，严夫人的丈夫是吕布，吕布的妻子却是 “貂蝉”了。这也是正和家谱里面的显示对应！！！
--==============================================================================--

CharacterExOp_marry_byHy = {
    modify_character_spouse = {}, --新人原来的伴侣
}

function CharacterExOp_marry_byHy:is_can_marry(query_character, query_faction_leader)
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
function CharacterExOp_marry_byHy:marry_wife(query_character, modify_character, query_faction, modify_faction)
    local query_faction_leader = query_faction:faction_leader();
    if (not self:is_can_marry(query_character, query_faction_leader)) then
        return ;
    end
    --无论主公现在是否有伴侣，执行纳妻，新人直接成为正室
    local dilemma_marry = cm:modify_model():create_dilemma("dilemmas_纳妻");
    dilemma_marry:add_character_target("target_character_1", query_character);--新人
    dilemma_marry:add_character_target("target_character_2", query_faction_leader);--主公
    dilemma_marry:add_faction_target("target_faction_1", query_faction);
    if (query_character:family_member():has_spouse()) then
        table.insert(CharacterExOp_marry_byHy.modify_character_spouse, cm:modify_character(query_character:family_member():spouse():character():cqi()))
    end
    dilemma_marry:trigger(modify_faction, true);

    --扣除国库
    modify_faction:decrease_treasury(300)
    ModLog("FactionEffectBundleAwarded--执行, 【纳妻】，国库减少300");
end

--纳妾（新人成为侧室）
function CharacterExOp_marry_byHy:marry_concubine(query_character, modify_character, query_faction, modify_faction)
    local query_faction_leader = query_faction:faction_leader();
    if (not self:is_can_marry(query_character, query_faction_leader)) then
        return ;
    end
    if (not query_faction_leader:family_member():has_spouse()) then
        --主公没有伴侣，执行纳妻
        local dilemma_marry = cm:modify_model():create_dilemma("dilemmas_纳妻");
        dilemma_marry:add_character_target("target_character_1", query_character);--新人
        dilemma_marry:add_character_target("target_character_2", query_faction_leader);--主公
        dilemma_marry:add_faction_target("target_faction_1", query_faction);
        if (query_character:family_member():has_spouse()) then
            table.insert(CharacterExOp_marry_byHy.modify_character_spouse, cm:modify_character(query_character:family_member():spouse():character():cqi()))
        end
        dilemma_marry:trigger(modify_faction, true);
    else
        --主公有伴侣，执行纳妾
        local dilemma_marry = cm:modify_model():create_dilemma("dilemmas_纳妾");
        dilemma_marry:add_character_target("target_character_1", query_character);--新人
        dilemma_marry:add_character_target("target_character_2", query_faction_leader);--主公
        dilemma_marry:add_character_target("target_character_3", query_faction_leader:family_member():spouse():character());--主公的原配
        dilemma_marry:add_faction_target("target_faction_1", query_faction);
        if (query_character:family_member():has_spouse()) then
            table.insert(CharacterExOp_marry_byHy.modify_character_spouse, cm:modify_character(query_character:family_member():spouse():character():cqi()))
        end
        dilemma_marry:trigger(modify_faction, true);
    end
    --扣除国库
    modify_faction:decrease_treasury(100)
    ModLog("FactionEffectBundleAwarded--执行, 【纳妾】，国库减少100");
end

core:add_listener(
        "listen_character_ex_op_marry_byHy", -- Unique handle
        "DilemmaChoiceMadeEvent", -- Campaign Event to listen for
        function(context)
            local dilemma = context:dilemma()
            --选择FIRST   context:choice() = 0
            --选择SECOND   context:choice() = 1
            return (dilemma == "dilemmas_纳妾" or dilemma == "dilemmas_纳妻") and context:choice() == 1
        end,
        function(context)
            if (#CharacterExOp_marry_byHy.modify_character_spouse > 0) then
                for i = 1, #CharacterExOp_marry_byHy.modify_character_spouse do
                    --此处只需要 新人旧伴侣的离婚即可，新人不可离婚，否则刚刚新人和主公的婚姻会消失
                    --divorce_spouse()函数，只会单方面解除婚姻，只有当双方都执行divorce_spouse()时，双方彼此之间才会解除婚姻关系
                    CharacterExOp_marry_byHy.modify_character_spouse[i]:family_member():divorce_spouse()
                    ModLog("FactionEffectBundleAwarded--执行, 【纳妻/妾】，新人之前存在伴侣，执行新人的旧伴侣离婚" .. CharacterExOp_marry_byHy.modify_character_spouse[i]:query_character():generation_template_key());
                end
                CharacterExOp_marry_byHy.modify_character_spouse = {}
            end
        end,
        true
);

