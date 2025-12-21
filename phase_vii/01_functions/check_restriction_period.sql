-- ============================================
-- FUNCTION: CHECK_RESTRICTION_PERIOD
-- Purpose: Checks if DML operations are allowed
-- Returns: 'ALLOWED', 'WEEKDAY_RESTRICTION', or 'HOLIDAY_RESTRICTION'
-- ============================================
CREATE OR REPLACE FUNCTION CHECK_RESTRICTION_PERIOD 
RETURN VARCHAR2 
IS
    v_day_of_week VARCHAR2(3);
    v_is_holiday  NUMBER;
BEGIN
    -- Get day of week
    v_day_of_week := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');
    
    -- Check if weekday (Mon-Fri)
    IF v_day_of_week IN ('MON', 'TUE', 'WED', 'THU', 'FRI') THEN
        RETURN 'WEEKDAY_RESTRICTION';
    END IF;
    
    -- Check if public holiday in next month
    SELECT COUNT(*)
    INTO v_is_holiday
    FROM HOLIDAY
    WHERE HOLIDAY_DATE = TRUNC(SYSDATE)
      AND HOLIDAY_TYPE = 'PUBLIC'
      AND HOLIDAY_DATE BETWEEN TRUNC(SYSDATE) AND ADD_MONTHS(TRUNC(SYSDATE), 1);
    
    IF v_is_holiday > 0 THEN
        RETURN 'HOLIDAY_RESTRICTION';
    END IF;
    
    RETURN 'ALLOWED';
END CHECK_RESTRICTION_PERIOD;
/
