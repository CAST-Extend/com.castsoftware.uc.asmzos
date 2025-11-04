"""

Generalised text split by spaces and by a list of 'separators' taht can be one or several characters.

Usage : 

    s = Splitter(['(','=',')'])
    s.split("IF (VAR=1 OR 2)")
    --> ['IF', ' ', '(', 'VAR', '=', '1', ' ', 'OR', ' ', '2', ')']

class Splitter:

    def __init__(self, separators):
        ...
        
    def split(self, text):
        '''
        Split a text into several element using separators and blanks
         
        separators is a list of strings, for example ['(', '=>', ')']
        separators, blanks are returned as is
         
        returns an iterable of string
        '''    


"""

try:
    # try using 64 bit C++ implemented version if possible
    from .utility_functions import Splitter # @UnresolvedImport
except:
    # python fall back
    class Splitter:
        
        def __init__(self, separators):
            
            self.mono_char_separators = set([s for s in separators if len(s)==1])
            self.multi_char_separators = [s for s in separators if len(s)>1]
            
        
        def split(self, text):
        
            
            # for mono/multi-char separators
            
            result = []
        
            have_current_token = False
            current_token = None
            current_token_is_blanks = False
        
            i = 0;
            while i < len(text):
                c = text[i];
        #         print('scanning', c)
                # number of remaining chars from this one
                rest = len(text) - i;
        
                character_is_blanks = c.isspace()
        
                if not character_is_blanks:
                    # search for maximum multi char
                    current_max_multi = ''
        
                    for multi in self.multi_char_separators:
                        if (c == multi[0] and len(multi) <= rest and len(multi) > len(current_max_multi) and text[i:i+len(multi)] == multi):
                            current_max_multi = multi;
        
                    if current_max_multi:
                        if (have_current_token):
                            result.append(current_token);
                            have_current_token = False
        
                        result.append(current_max_multi);
        
                        # increase i
                        i += len(current_max_multi);
                        continue;
        
                    # search for mono char separators
                    is_mono_char_separator = c in self.mono_char_separators
        
                    if (is_mono_char_separator):
        #                 print(c, "is_mono_char_separator")
                        #std::cout << c << " is_mono_char_separator" << std::endl;
        
                        if (have_current_token):
        #                     print("appending", current_token)
                            #std::cout << "appending " << current_token << std::endl;
        
                            result.append(current_token);
                            current_token = "";
        
                        result.append(c);
                        current_token_is_blanks = False;
                        have_current_token = False;
                    
                    else:
        #                 print(c, 'is not separator')
                        #std::cout << c << " is not separator" << std::endl;
                        if (have_current_token):
                            if (current_token_is_blanks):
                                result.append(current_token);
                                current_token = c;
                                current_token_is_blanks = False;
                            else:
                                current_token += c;
                        else:
                            current_token = c;
                            have_current_token = True;
                            current_token_is_blanks = False;
                else:
                    # seen a blank
                    if (have_current_token):
                        if (current_token_is_blanks):
                            current_token += c;
                        else:
                            result.append(current_token);
                            current_token_is_blanks = True;
                            current_token = c;
                    else:
                        have_current_token = True;
                        current_token_is_blanks = True;
                        current_token = c;
                i += 1;
        
            # last one as is...
            if (have_current_token):
                result.append(current_token);
        
            return result;

# 
# def split(text, separators):
#     
#     return split_python(text, separators)
# 
# def split_cpp(text, separators):
#     """
#     Split a text into several element using separators and blanks
#     
#     separators is a list of strings, for example ['(', '=>', ')']
#     separators, blanks are returned as is
#     
#     returns an iterable of string
#     """
#     s = Splitter(separators)
#     return s.split(text)
# 
# def split_python(text, separators):
#     """
#     Split a text into several element using separators and blanks
#     
#     separators is a list of strings, for example ['(', '=>', ')']
#     separators, blanks are returned as is
#     
#     returns an iterable of string
#     """


