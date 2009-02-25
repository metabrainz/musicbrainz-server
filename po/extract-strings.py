def extract_tt_strings(lines):
    """Extract all TT strings marked with [% %]"""

    count = 0
    string_started = False
    start_marker_started = False
    end_marker_started = False
    string = ""
    for line in lines:
        count += 1
        for char in line:
            if string_started:
                string += char                

            if start_marker_started:
                if char == "%":
                    linum = count
                    string_started = True
                    start_marker_started = False
                    string = "[%"
                else:
                    start_marker_started = False                

            if end_marker_started:
                if char == "]":
                    string_started = False
                    end_marker_started = False
                    yield(linum, string)
                    string = ""
                else:
                    end_marker_started = False
                    
            if char == "[":
                start_marker_started = True                

            if string_started:
                if char == "%":
                    end_marker_started = True


def extract_tt(fileobj, keywords, comment_tags, options):
    """Extract messages from TemplateToolkit files.
    :param fileobj: the file-like object the messages should be extracted
    from
    :param keywords: a list of keywords (i.e. function names) that should
    be recognized as translation functions
    :param comment_tags: a list of translator tags to search for and
    include in the results
    :param options: a dictionary of additional options (optional)
    :return: an iterator over ``(lineno, funcname, message, comments)``
    tuples
    :rtype ``iterator``
    """

    # TODO: Extract comments, contexts etc.

    from template.parser import Parser
    parser = Parser({})

    lines = fileobj.readlines()

    # We are doing our own parsing, since it makes extracting line numbers easier
    for (line,string) in extract_tt_strings(lines):

        parsed = parser.split_text(string)
        if parsed:
            parsed = parsed[0][2]

        message_plural = ""

        # '-7' because it the minimal list length in which a l() function can appear
        # '[8:-2]' removes "scalar()" from the string
        for i  in xrange(0, len(parsed)-7):
            # Scan for 'IDENT', 'l', '(', '(', 'LITERAL' (l('some text'))
            if parsed[i] == "IDENT" and parsed[i+1] in keywords and parsed[i+2:i+5] == ["(", "(", "LITERAL"]:
                message = parsed[i+5][8:-2].decode("string_escape")
                if parsed[i+6:i+9] == ['COMMA', ',', 'LITERAL']:
                    message_plural = parsed[i+9][8:-2]
                yield (line, parsed[i+1], (message, message_plural), comment_tags and comments or [])
