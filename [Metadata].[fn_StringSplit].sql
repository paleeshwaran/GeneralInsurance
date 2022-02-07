/****** Object:  UserDefinedFunction [Metadata].[fn_StringSplit]    Script Date: 7/02/2022 6:48:37 pm ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE function [Metadata].[fn_StringSplit]
(
    @str nvarchar(max) = ' '            -- String to split.
    ,@delimiter as nvarchar(255) = ','  -- Delimiting value to split on.
    ,@num as int = null                 -- Which value to return, null returns all.
)
returns table with SCHEMABINDING
as
    return
    (
        with d as
        (
            select rn = row_number() over (order by (select null))
                    ,item = y.i.value('(./text())[1]', 'nvarchar(max)')
            from(select x = convert(xml, '<i>'
                                    + replace((select @str for xml path('')), @delimiter, '</i><i>')
                                    + '</i>'
                                    ).query('.')
                ) AS a
                    cross apply x.nodes('i') AS y(i)
        )
        select rn
                ,item
        from d
        where rn = @num
            or @num is null
    );
GO


