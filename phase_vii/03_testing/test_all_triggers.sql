-- Comprehensive trigger testing
SET SERVEROUTPUT ON;

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== COMPREHENSIVE TRIGGER TESTING ===');
    DBMS_OUTPUT.PUT_LINE('Date: ' || TO_CHAR(SYSDATE, 'Day, YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Restriction Status: ' || CHECK_RESTRICTION_PERIOD());
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test FARM trigger
    DBMS_OUTPUT.PUT_LINE('1. Testing FARM trigger:');
    BEGIN
        INSERT INTO FARM (FARM_ID, FARM_NAME, LOCATION, CROP_TYPE_ID) 
        VALUES (99997, 'Trigger Test', 'Test', 1000);
        DBMS_OUTPUT.PUT_LINE('   Result: ALLOWED');
        ROLLBACK;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   Result: BLOCKED - ' || SUBSTR(SQLERRM, 1, 100));
    END;
    
    -- Test INVENTORY trigger
    DBMS_OUTPUT.PUT_LINE('2. Testing INVENTORY trigger:');
    BEGIN
        INSERT INTO INVENTORY (INVENTORY_ID, ITEM_NAME, QUANTITY) 
        VALUES (99999, 'Test Item', 100);
        DBMS_OUTPUT.PUT_LINE('   Result: ALLOWED');
        ROLLBACK;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   Result: BLOCKED - ' || SUBSTR(SQLERRM, 1, 100));
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== TEST COMPLETE ===');
END;
/
