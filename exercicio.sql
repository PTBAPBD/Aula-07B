CREATE PROCEDURE dbo.salaryHistogram 
    @numIntervals INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @minSalary DECIMAL(10,2),
            @maxSalary DECIMAL(10,2),
            @intervalWidth DECIMAL(10,2),
            @i INT = 0,
            @lowerBound DECIMAL(10,2),
            @upperBound DECIMAL(10,2);

    --  o menor e maior salário de instrutor
    SELECT 
        @minSalary = MIN(salary),
        @maxSalary = MAX(salary)
    FROM instructor;

    -- caso todos os salários sejam iguais
    IF @minSalary = @maxSalary
    BEGIN
        SELECT 
            @minSalary AS LimiteInferior,
            @maxSalary AS LimiteSuperior,
            COUNT(*) AS Frequencia
        FROM instructor;
        RETURN;
    END

    -- tamanho de cada intervalo
    SET @intervalWidth = (@maxSalary - @minSalary) / @numIntervals;

    --  tabela temporária 
    CREATE TABLE #Histogram (
        LimiteInferior DECIMAL(10,2),
        LimiteSuperior DECIMAL(10,2),
        Frequencia INT
    );

    -- calcula os intervalos e frequências
    WHILE @i < @numIntervals
    BEGIN
        SET @lowerBound = @minSalary + (@intervalWidth * @i);
        SET @upperBound = @lowerBound + @intervalWidth;

        INSERT INTO #Histogram
        SELECT 
            @lowerBound,
            @upperBound,
            COUNT(*)
        FROM instructor
        WHERE salary >= @lowerBound AND 
              (
                  salary < @upperBound OR 
                  (@i = @numIntervals - 1 AND salary <= @upperBound)
              );

        SET @i += 1;
    END

    --  histograma
    SELECT 
        LimiteInferior,
        LimiteSuperior,
        Frequencia
    FROM #Histogram
    ORDER BY LimiteInferior;

    -- remove a tabela 
    DROP TABLE #Histogram;
END;


EXEC dbo.salaryHistogram 5; 

