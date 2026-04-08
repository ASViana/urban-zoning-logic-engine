-- PROTOCOL RITUAL DEFINITION
-- Identifies the legal context of the request based on system events.
SET @Ritual = 
    CASE 
        -- If there are only activity removals, the ritual is simplified
        WHEN @Qty_Exclusions > 0 AND @Qty_Inclusions = 0 AND @Address_Change = 0 
		AND @Event = 'Activity_Change'
	THEN 'DIRECT_APPROVAL'
        
        -- If it is a change without new impacts, focus on grandfathered rights
        WHEN (@Event = 'Activity_Change' OR @Event = 'Registration_Change') 
             AND @Address_Change = 0 AND @Qty_Inclusions = 0 THEN 'GRANDFATHERED_RIGHTS'
        
        -- Default for new businesses or address changes
        ELSE 'NEW_FEASIBILITY' 
    END;

-- WEIGHT CALCULATION
-- Processes law classification to generate the Risk Weight.
-- This block runs for each reported Activity Code (CNAE) and crosses it with zoning.
-- @Classification refers to the law classification for the Activity/Zone context.
-- The engine assumes @Classification is already normalized (Ex: '1', '1*', '3', '7').
-- In cases of multiple classifications, the system evaluates the most restrictive via this engine.
SET @Activity_Weight = 
    CASE 
        -- PRIORITY 1: PROHIBITED (Classification 7 or Null)
        WHEN @Classification IS NULL OR @Classification = '7' THEN 5

        -- PRIORITY 2: TECHNICAL ANALYSIS / BOARD REVIEW (Classification 2, 4 or area excess with appeal possibility)
	    -- Activated for pure classification 2 or 4, or if area exceeds limit in 1* or 3* with Board Review path.
        WHEN @Classification = '2' 
                OR @Classification = '4' 
		OR (@Classification = '1*' AND @Total_Area > @Area_Limit AND @Board_Review_Possible = 1)
		OR (@Classification = '3*' AND @Total_Area > @Area_Limit AND @Board_Review_Possible = 1)
	THEN 4

        -- PRIORITY 3: AREA BLOCK (Exceeds limit in 1* or 3* without appeal)
        WHEN (@Classification IN ('1*', '3*') AND @Total_Area > @Area_Limit) THEN 5

        -- PRIORITY 4: GRANDFATHERED RIGHTS (Specific ritual for 5 and 6)
        WHEN @Ritual = 'GRANDFATHERED_RIGHTS' AND @Classification = '6' THEN 3
        WHEN @Ritual = 'GRANDFATHERED_RIGHTS' AND @Classification = '5' THEN 2

        -- PRIORITY 5: CONDITIONAL (Classification 3)
        WHEN @Classification = '3' OR @Classification = '3*' THEN
            CASE 
                -- Maintains Weight 1 for Administrative Offices to ensure conditional terms acceptance
                WHEN @Administrative_Office = 1 THEN 1 
                WHEN @Terms_Acceptance = 0 THEN 5 
                ELSE 1 
            END

        -- PRIORITY 6: RELEASED (Classification 1)
        WHEN @Classification = '1' OR (@Classification = '1*' AND @Total_Area <= @Area_Limit) THEN 0

        ELSE 5 
    END;

-- FINAL VERDICT
-- The highest weight (most restrictive) among the reported activities prevails.
SET @Final_Verdict = 
    CASE @Max_Weight
        WHEN 0 THEN 'AUTOMATICALLY APPROVED'
        WHEN 1 THEN 'CONDITIONALLY APPROVED'
        WHEN 2 THEN 'DENIED (REQUERES PROOF OF GRANDFATHERED RIGHTS)'
        WHEN 3 THEN 'DENIED (INCOMPATIBLE USE)'
        WHEN 4 THEN 'FORWARDED FOR TECHNICAL ANALYSIS / BOARD REVIEW'
        WHEN 5 THEN 'DENIED (PROHIBITED)'
    END;
