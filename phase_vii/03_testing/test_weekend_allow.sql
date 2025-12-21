-- Test: Weekend Allowance
-- Expected: Operations should be allowed
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST: WEEKEND ALLOWANCE ===');
    DBMS_OUTPUT.PUT_LINE('Note: This test assumes today is weekend (Sat-Sun)');
    DBMS_OUTPUT.PUT_LINE('Restriction status: ' || CHECK_RESTRICTION_PERIOD());
    
    -- Only attempt if allowed
    IF CHECK_RESTRICTION_PERIOD() = 'ALLOWED' THEN
        BEGIN
            INSERT INTO FARM (FARM_ID, FARM_NAME, LOCATION, CROP_TYPE_ID) 
            VALUES (99998, 'Weekend Test Farm', 'Test', 1000);
            DBMS_OUTPUT.PUT_LINE('✓ PASS: Insert allowed on weekend');
            ROLLBACK;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('✗ FAIL: ' || SQLERRM);
        END;
    ELSE
        DBMS_OUTPUT.PUT_LINE('SKIP: Today is not weekend');
    END IF;
END;
/
