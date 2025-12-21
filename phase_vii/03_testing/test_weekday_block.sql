-- Test: Weekday Restriction
-- Expected: Operations should be blocked
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST: WEEKDAY RESTRICTION ===');
    DBMS_OUTPUT.PUT_LINE('Note: This test assumes today is a weekday (Mon-Fri)');
    DBMS_OUTPUT.PUT_LINE('Restriction status: ' || CHECK_RESTRICTION_PERIOD());
    
    -- Try to insert (should fail on weekday)
    BEGIN
        INSERT INTO FARM (FARM_ID, FARM_NAME, LOCATION, CROP_TYPE_ID) 
        VALUES (99999, 'Test Farm', 'Test Location', 1000);
        DBMS_OUTPUT.PUT_LINE('ERROR: Insert should have been blocked!');
        ROLLBACK;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('✓ PASS: Insert correctly blocked');
            DBMS_OUTPUT.PUT_LINE('  Error message: ' || SQLERRM);
    END;
END;
/
