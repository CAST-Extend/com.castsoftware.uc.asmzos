'''
Created on 30 oct. 2014

@author: MRO

'''
from pygments.filter import Filter
from pygments.lexer import Lexer
from pygments.token import Keyword, Whitespace, Comment, is_token_subtype, _TokenType, Literal
from pygments.token import Token as PygmentToken
import traceback, weakref
import binascii
import itertools
import math
from collections import defaultdict

__version__ = "2.0.15"


class Parser:
    """
    A non validating parser made of one lexer and 'statement' types.
    """
    def __init__(self, lexer_type, statements, *args, **kwargs): 
        """
        @param lexer: a lexer type 
        @param statements: list of Statement type to recognize
        
        
        @param case_sensitive: bool default False 
           is the matching of token case sensitive
        
        
        """
        
        case_sensitive = False
        try:
            case_sensitive = kwargs['case_sensitive']
        except:
            pass
        
        self.lexer = create_lexer(lexer_type, case_sensitive)
        
        self.filters = []
        self.filters.append(StatementFilter(statements))
        
        for x in args:
            
            self.filters.append(StatementFilter(x))
    
    def use_indentation(self):
        """
        Indentation increase/decrease tokens are inserted in the token flux.
        So that they can be used as begin/end.
        
        Those tokens are : light_parser.IncreaseIndent ; light_parser.DecreaseIndent
                
        """
        self.lexer.add_filter(IndentFilter())
    
    def parse(self, text):
        """
        Parse a text and return a stream of AST nodes / tokens.
        """
        if not type(text) is str:
            text = text.read()
     
        stream = Lookahead(self.lexer.get_tokens(text))
        
        return self.parse_stream(stream)
    
    def parse_stream(self, stream):
        """
        Parse a stream and return a stream of AST nodes / tokens.
        """
        for f in self.filters:
            stream = Lookahead(f.process(stream))
        
        return stream


class Walker:
    """
    Walk a AST.
    
    Usage : 
    - register interpreters.
    - if they have methods : 
    
        start_<node type>(self, node) 
        end_<node type>(self, node)
    
    then they will be called...
    """
    def __init__(self):
        self.interpreters = []    

    def register_interpreter(self, interpreter):
        self.interpreters.append(interpreter)

    def walk(self, stream):
        """
        walk a stream an broadcast to interperters
        """
        for element in stream:
            
            if isinstance(element, Node):
                name = type(element).__name__
                
                # call the start
                for interpreter in self.interpreters:
                    
                    if hasattr(interpreter, 'start_node'):
                        getattr(interpreter, 'start_node')(element)
                    
                    if hasattr(interpreter, 'start_' + name):
                        getattr(interpreter, 'start_' + name)(element)
                
                # recurse
                element.walk(self)
                
                # call the ends
                for interpreter in self.interpreters:

                    if hasattr(interpreter, 'end_' + name):
                        getattr(interpreter, 'end_' + name)(element)

                    if hasattr(interpreter, 'end_node'):
                        getattr(interpreter, 'end_node')(element)


class AnyPath:
    """
    Equivalent of '//' in XPath
    
    Will match any sub list of node (from 0 to infinite)
    """
    pass

    
class NodePath:
    """
    Use this for more control on matching rules
    XPath on nodes.
    
    parser = Parser(..., 
                    [...],
                    {NodePath(AnyPath, Class, Bracket): [...], # equivalent to //Class/Bracket
                     ...}
                     
    meaning that we apply some specific rule directly inside the Bracket under Class (but not inside sub nodes of Brackets)
    
    Classical notation : 
    
    parser = Parser(..., 
                    [...],
                    {Bracket: [...], # equivalent to NodePath(AnyPath, Bracket, AnyPath)
                     ...}
     
    """
    
    def __init__(self, *args):
        
        # @todo check for AnyPath, AnyPath and normalize.
        self.xpath = args
        
    
    def match(self, node_path):
        """
        Return true when node_path matches this pattern 
        """
        
        return NodePath._math(self.xpath, node_path)
    
    @staticmethod
    def _math(xpath, node_path):
        """
        xpath list of ...
        node_path list of nodes
        """
        
#         print('_math', xpath, node_path)
        
        if not xpath:
            # empty list match empty list
#             print('  ', not node_path)
            return not node_path
        
        if not node_path:
            
            if xpath[-1] == AnyPath and len(xpath) == 1:
#                 print('  ', True)
                return True
            
            # do not handle the stupid : [AnyPath, AnyPath]
#             print('  ', False)
            return False
        
        
        if xpath[-1] == AnyPath:
            
            # switch ...
            # either AnyPath is not used, or it is used.
            result = NodePath._math(xpath[:-1], node_path) or NodePath._math(xpath, node_path[:-1])
#             print('  ', result)
            return result
        
        else:
            last_node = node_path[-1]
            if not isinstance(last_node, xpath[-1]):
#                 print('  ', False)
                return False
            
            result = NodePath._math(xpath[:-1], node_path[:-1])
#             print('  ', result)
            return result
        
        
    




def create_lexer(lexer_type, case_sensitive=False):
    """
    Create a lexer from a lexer_type.
    
    @param lexer_type: a lexer as from pygments.lexers
    """
    lexer = lexer_type(stripnl=False)
    lexer.add_filter(PositionFilter(case_sensitive=case_sensitive))
    return lexer


class Token:
    """
    A token with code position.
    """
    def __init__(self, text=None, type=None, case_sensitive=False):
        
        self.type = type
        self.text = text
        self.begin_line = None
        self.begin_column = None
        self.end_line = None
        self.end_column = None
        self._is_whitespace = False
        self._is_comment = False
        self.lower_text = text.lower() if text else None
        self._calculate()
        self.case_sensitive = case_sensitive

    def get_type(self):
        return self.type

    def get_begin_line(self):
        return self.begin_line

    def get_begin_column(self):
        return self.begin_column

    def get_end_line(self):
        return self.end_line

    def get_end_column(self):
        return self.end_column

    def get_header_comments(self):
        """Get the header comments"""
        return []

    def get_body_comments(self):
        """Get the body comments"""
        return []
    
    def get_line_count(self):
        """
        Number of lines of the node
        
        Also count empty lines.
        """
        return self.get_end_line() - self.get_begin_line() + 1
    
    def is_whitespace(self):
        "Token is whitespace."
        return self._is_whitespace

    def is_comment(self):
        "Token is comment."
        return self._is_comment
        
    def _calculate(self):
        
        self._is_whitespace = self.__is_whitespace()
        self._is_comment = self.__is_comment()
    
    def __is_whitespace(self):
        "Token is whitespace."
        if self.type == Whitespace:
            return True
        if self.type in [IncreaseIndent, DecreaseIndent]:
            return False
        return not self.text or self.text.isspace()
    
    def __is_comment(self):
        "Token is comment."
        return is_token_subtype(self.type, Comment)
    
    def print_tree(self, depth=0):
        indent = ' ' * (depth * 2)
        print(indent, self)
    
    def get_sub_nodes(self):
        return []

    def get_children(self):
        return []
    
    def _get_code_only_crc(self, initial_crc=0):
        """
        Get the crc of the code
        """
        if self.text:
            return binascii.crc32(bytes(self.text, 'UTF-8'), initial_crc)
        return initial_crc
    
    def get_code_only_crc(self, initial_crc=0):
        """
        Get the crc of the code
        """
        return self._get_code_only_crc(initial_crc)  - 2**31
    
    def __eq__(self, other):
        """
        Equality to other token or text
        """
        if type(other) is str:
            if self.case_sensitive:
                return self.text == other
            else:
                return self.text.lower() == other.lower()
                
        else:
            if self.case_sensitive:
                return self.text == other
            else:
                return self.text.lower() == other
    
    def __repr__(self):
        result = 'Token(' + repr(self.type) + "," + repr(self.text)
        result += "," + repr(self.begin_line)
        result += "," + repr(self.begin_column)
        result += "," + repr(self.end_line)
        result += "," + repr(self.end_column)
        return result + ")"


IncreaseIndent     = PygmentToken.IncreaseIndent
DecreaseIndent     = PygmentToken.DecreaseIndent


class IndentFilter(Filter):
    """
    Filter that add indentation tokens in the stream.
    
    This filter will insert in the stream special tokens IncreaseIndent, DecreaseIndent 
    """
    def __init__(self):
        
        # current column line
        self.current_column = 1
        self.new_line = False
        # we can deduce the indentation used
        self.deduced_indentation = 0

    def filter(self, lexer, stream):
    
        for token in stream:

            if token.is_whitespace():
                
                if '\n' in token.text:
                    # we have changed line
                    self.new_line = True
            
            else:
                
                if self.new_line:
                    
                    # this is a new line and this is the current indentation column given by the first text
                    column = token.begin_column
                    
                    if column > self.current_column: # indentation level has increased
                        
                        # calibrate the 'size of indentation':
                        if not self.deduced_indentation:
                            self.deduced_indentation = column - 1
                        
                        if not is_token_subtype(Comment, token.type) and not is_token_subtype(Literal.String, token.type):
                            nbIndent = math.floor((column-self.current_column)/self.deduced_indentation)
                            for _ in range(nbIndent):
                                yield Token(type=IncreaseIndent)

                    elif column < self.current_column and not is_token_subtype(Comment, token.type) and not is_token_subtype(Literal.String, token.type): # decrease of indentation
                        
                        # we can 'close' several blocks at one time : we use deduced_indentation to know how many 
                        # decrease we should get 
                        while column < self.current_column:
                        
                            yield Token(type=DecreaseIndent)
                            self.current_column -= self.deduced_indentation
                    
                    # the current 'indent'
                    if not is_token_subtype(Comment, token.type) and not is_token_subtype(Literal.String, token.type):
                        self.current_column = column
                
                # waiting for a new line
                self.new_line = False
        
            # still give the current token...
            yield token 
        
    def filter1(self, lexer, stream):
        
        for token in stream:
            
            print('current token', token)
            print('previous is new line', self.new_line)
            print('current_indent', self.current_column)
            if token.is_whitespace():
                
                if token.text == '\n':
                    self.new_line = True
                elif '\n' in token.text or self.new_line:
                    indent = token.end_column - 1
                    if indent > self.current_column:
                        print('increase')
                        yield Token(type=IncreaseIndent)
                    elif indent < self.current_column:
                        print('decrease')
                        yield Token(type=DecreaseIndent)
                    
                    self.current_column = indent
                
                if '\n' not in token.text:
                    self.new_line = False
                
            else:
                if self.new_line:
                    indent = token.begin_column
                    print('indent', indent)
                    if indent > self.current_column:
                        print('increase')
                        yield Token(type=IncreaseIndent)
                    elif indent < self.current_column:
                        print('decrease')
                        yield Token(type=DecreaseIndent)
                    
                    self.current_column = indent
                    
                self.new_line = False
                
            yield token 


class PositionFilter(Filter):
    """
    Filter that add position to tokens.
    """
    def __init__(self, case_sensitive=False):
        
        self.column = 1 
        self.line = 1
        self.case_sensitive = case_sensitive
        
    def filter(self, lexer, stream):
        
        for token in stream:
            
            end_line, end_column = self.get_end_position(token[1]) 
            
            new_token = Token(text=token[1], type=token[0], case_sensitive=self.case_sensitive)
                
            new_token.begin_line = self.line
            new_token.begin_column = self.column
            new_token.end_line = end_line
            new_token.end_column = end_column
            
            self.line = end_line
            self.column = end_column
            
            yield new_token 
    
    def get_end_position(self, text):
        
        end_line = self.line
        end_column = self.column
        
        for c in text:
            
            if c == '\n':
                end_line += 1
                end_column = 1
            else:
                end_column += 1
        
        return end_line, end_column
        


class Seq:
    """A pattern made of element in a specific order"""
    def __init__(self, *args):
        self.list = args

    def check(self):
        return True        

    def __repr__(self):
        return 'Seq(' + ','.join(str(p) for p in self.list) + ')'


class Or:
    
    def __init__(self, *args):
        self.list = args

    def check(self):
        for pattern in self.list:
            if type(pattern) is Optional:
                return False 
        return True

    def __repr__(self):
        return 'Or(' + ','.join(str(p) for p in self.list) + ')'

  
class Optional:
    """An optional pattern inside a Seq"""
    def __init__(self, pattern):
        self.pattern = pattern

    def check(self):
        return True
    
    def __repr__(self):
        return 'Optional(' + str(self.pattern) + ')'


class Not:
    """Not a token"""
    def __init__(self, pattern):
        self.pattern = pattern

    def check(self):
        return True
    
    def __repr__(self):
        return 'Not(' + str(self.pattern) + ')'


class NotFollowedBy:
    """
    Not a token in lookahead mode
    
    Usage : 
    
    Seq('USING', NotFollowedBy(Parenthesis))
    
    Will match USING when not followed by (...) but not consuming the token after using
    """
    def __init__(self, pattern):
        self.pattern = pattern

    def check(self):
        return True
    
    def __repr__(self):
        return 'NotFollowedBy(' + str(self.pattern) + ')'


class Any:
    """Any token"""
    def check(self):
        return True

    def __repr__(self):
        return 'Any()' 


class Repeat:
    """
    The repeat of something
    
    Repeat(Annotation) will match Annotation Annotation Annotation 
    """
    def __init__(self, pattern):
        self.pattern = pattern
    
    def check(self):
        return True
    
    def __repr__(self):
        return 'Repeat(' + str(self.pattern) + ')'

    
    
class Node:
    """
    An AST node
    
    """
    # default : do we put end inside the Node 
    consume_end = True
    
    def __init__(self):
        
        # for compat Token/Node
        self.text = None
        self.lower_text = None
        self.type = None

        # all the sub tokens/nodes
        self.children = []
        
        self.header_comments_length = 0
        self.header_length = 0
        self.begin_length = 0
        self.end_length = 0
        
        # deprecated : to remove after usage
        self.header_comments = []
        self.header = []
    
    def get_type(self):
        return type(self).__name__
    
    def on_end(self):
        """
        Called after end parsing
        
        One can override it for fancy stuffs.
        """
        pass
    
    def get_header(self):
        """
        Get an iterator on the full content of header.
        """
        return Lookahead(TokenIterator(itertools.islice(self.children, 
                                                        self.header_comments_length, 
                                                        self.header_comments_length+self.header_length)))

    def get_body(self):
        """
        Get an iterator on the full content of body.
        Including begin and end
        """
        body_index = self.header_comments_length+self.header_length
        return Lookahead(TokenIterator(itertools.islice(self.children, body_index, None)))

    def get_inner_body(self):
        """
        Get an iterator on the inner content of body.
        It excludes begin and end
        """
        inner_body_index = self.header_comments_length+self.header_length+self.begin_length
        end = len(self.children) - self.end_length
        return Lookahead(TokenIterator(itertools.islice(self.children, inner_body_index, end)))

    def get_begin_line(self):
        ret = None
        index = 0
        childrenLen = len(self.children)
        while not ret and index < childrenLen:
            ret = self.children[index].get_begin_line()
            index += 1
        return ret

    def get_begin_column(self):
        ret = None
        index = 0
        childrenLen = len(self.children)
        while not ret and index < childrenLen:
            ret = self.children[index].get_begin_column()
            index += 1
        return ret

    def get_code_begin_line(self):
        """
        First line of code (without header comments)
        """
        children = self.get_children()
        return next(children).get_begin_line()

    def get_code_begin_column(self):
        """
        First column of code (without header comments)
        """
        children = self.get_children()
        return next(children).get_begin_column()
        
    def get_end_line(self):
        ret = None
        childrenLen = len(self.children)
        index = childrenLen - 1
        while not ret and index >= 0:
            ret = self.children[index].get_end_line()
            index -= 1
        return ret

    def get_end_column(self):
        ret = None
        childrenLen = len(self.children)
        index = childrenLen - 1
        while not ret and index >= 0:
            ret = self.children[index].get_end_column()
            index -= 1
        return ret

    def get_children(self):
        "An iterator on tokens and children that skips whitespaces and comments"
        return Lookahead(TokenIterator(self.children))

    def get_sub_nodes(self, _type=None):
        """
        Return sub AST nodes
        
        if a _type is provided returns only sub nodes of that type.
        """
        if not _type:
            _type = Node
        return (child for child in self.children if isinstance(child, _type))
    
    def get_header_comments(self):
        """Get the header comments"""
        return [comment for comment in self.children[0:self.header_comments_length] if comment.is_comment()]

    def get_body_comments(self):
        """Get the body comments"""
        result = []
        body = False
        body_index = self.header_comments_length+self.header_length
        
        for token in self.children[body_index:]:
            if type(token) is Token:
                if token.is_comment() and body:
                    result.append(token)
                if not token.is_whitespace() and not token.is_comment():
                    body = True
            if isinstance(token, Node):
                result += token.get_body_comments()
        return result
    
    def get_line_count(self):
        """
        Number of lines of the node
        
        Also count empty lines.
        """
        return self.get_end_line() - self.get_begin_line() + 1
    
    def _get_code_only_crc(self, initial_crc=0):
        """
        Get the crc of the code without comments nor whitespaces
        """
        crc = initial_crc
        for token in self.get_children():
            try:
                crc = token._get_code_only_crc(crc)
            except:
                pass
        return crc
    
    def get_code_only_crc(self, initial_crc=0):
        """
        Get the crc of the code without comments nor whitespaces
        """
        return self._get_code_only_crc(initial_crc) - 2**31
    
    def is_whitespace(self):
        return False
    
    def is_comment(self):
        return False
    
    def print_tree(self, depth=0):
        """
        Print as a tree.
        """
        indent = ' ' * (depth * 2)
        print(indent, self.__class__.__name__)
        
        for token in self.children:
            token.print_tree(depth+1)

    def walk(self, walker):
        """
        Can be overriden for special treatments.
        """
        # default
        walker.walk(self.get_children())

    def __repr__(self):
        return self.__class__.__name__ + str(self.children)
        
    _last_matched_header = []
    
    
    def _split_block(self):
        """
        Return a split of the children :
        
        [....] [...] [...]
        header inner end
        begin
        
        """
        inner_body_index = self.header_comments_length+self.header_length+self.begin_length
        end = len(self.children) - self.end_length
        
        return (self.children[:inner_body_index], self.children[inner_body_index:end], self.children[end:])
    
    def _extract_body(self):
        """
        Extract the body
        """
        inner_body_index = self.header_comments_length+self.header_length+self.begin_length
        end = len(self.children) - self.end_length
        
        return self.children[inner_body_index:end]
    
    def _replace_body(self, new_body):
        """
        Replace the body by a new one
        """
        inner_body_index = self.header_comments_length+self.header_length+self.begin_length
        end = len(self.children) - self.end_length
        
        self.children = self.children[:inner_body_index] + new_body + self.children[end:]
    
    @staticmethod
    def match_header(node, token, stream):
        if hasattr(node, 'header'):
            return Node._match(node.header, token, stream)

    @staticmethod
    def match_begin(node, token, stream):
        return Node._match(node.begin, token, stream)

    @staticmethod
    def match_end(node, token, stream):
        return Node._match(node.end, token, stream, node.consume_end)
    
    @staticmethod
    def _match(pattern, token, stream, consume=True):
        """
        if token , stream matches pattern then return the tokens that matched
        else return []
        """
        stream.start_lookahead()
        result = None
        index_of_stream = stream.index
        try:
            result = Node.do_match(pattern, token, TokenIterator(stream))
        except StopIteration:
#             print('stopped', stream.index, index_of_stream)
            stream.index = index_of_stream

        if not result:
            # we do not consume the inspected tokens
            stream.stop_lookahead()
        else:
            
            if consume:
                # we consume the matching tokens 
                result = [token] + stream.stop_lookahead_and_consume()
            else:
                stream.stop_lookahead()
                # reput token in stream
                stream.tokens.insert(0, token)
                result = True
                
        return result
    
    @staticmethod
    def do_match(pattern, token, stream):
        
        t = type(pattern)
            
        if  t is str:
            if token.text and not is_token_subtype(token.type, Literal.String):
                return token.lower_text == pattern.lower()
            return False
        if t is _TokenType:
            # match by token type
            return is_token_subtype(token.type, pattern)
        
        if t is Token:
            # match by Token('text', type) : by both text and type
            return token.text == pattern.text and is_token_subtype(token.type, pattern.type)
            
        if t is Not:
            index_of_stream = stream.tokens.index
            if Node.do_match(pattern.pattern, token, stream):
                stream.tokens.index = index_of_stream
                return False
            return True
        
        if t is NotFollowedBy:
            temp = Node.do_match(pattern.pattern, token, stream)
#             print(pattern, token, temp)
            return not temp
        
        if t is Any:
            return True
        
        if  t is Optional:
            
#             print(pattern, token, stream)
            
            index_of_stream = stream.tokens.index
            if not Node.do_match(pattern.pattern, token, stream):
                # did not match : reput stream as before the call (work only in sequence)
                stream.tokens.index = index_of_stream
#                 print('did not match', stream)
                return False

#             print('did match', stream)
            return True
        
        elif t is Seq:
            
#             print('beginning ', stream.tokens.index)
            for p in pattern.list[:-1]:

                index_of_stream = stream.tokens.index
                
                t = type(p)
                opt = t is Optional
                not_followed_by = t is NotFollowedBy
                matched = Node.do_match(p, token, stream)

                index_of_stream = stream.tokens.index
                
                if not matched:
                    if not opt:
                        return False
                else:
                    if not_followed_by:
                        stream.tokens.index = index_of_stream
                    token = next(stream)
            
#             print('last pattern ', stream.tokens.index)
            
            last_pattern = pattern.list[-1]
            t = type(last_pattern)
            opt = t is Optional
            not_followed_by = t is NotFollowedBy
            matched = Node.do_match(last_pattern, token, stream)
            
            if opt:
                # last optional 
                if not matched:
                    stream.tokens.index = index_of_stream
                return True
            elif not_followed_by:
#                 print('not followed by')
                # whatever do not consume
                stream.tokens.index = index_of_stream
#                 print('index ', stream.tokens.index)
                return matched
            # else matched
            if matched:
                return True
            else:
                return False
        
        elif t is Or:
            for sub_pattern in pattern.list:

                # memorise the index of the lookahead stream                     
                index_of_stream = stream.tokens.index
                
                try:
                    if Node.do_match(sub_pattern, token, stream):
                        return True
                except StopIteration:
                    pass
                # did not match : reput stream as before
                stream.tokens.index = index_of_stream
            
            return False
        
        elif t is Repeat:
            
            index_of_stream = stream.tokens.index
            
            sub_pattern = pattern.pattern
            
            matched = False
            
            while Node.do_match(sub_pattern, token, stream):
                matched = True
                index_of_stream = stream.tokens.index
                token = next(stream)
            
            stream.tokens.index = index_of_stream
            
            return matched
        
        elif t is type:
            # a node type 
            return isinstance(token, pattern) 
        
        elif hasattr(pattern, "__call__"):
            # callable on token...
            # can be either : f(token) or f(token, stream)
            
            args_len = None
            if not hasattr(pattern, "__number_of_args"):
                args = inspect.getargspec(pattern).args
                args_len = len(args)
                setattr(pattern, "__number_of_args", args_len) 
            else:
                args_len = getattr(pattern, "__number_of_args")

            if args_len == 1:
                return pattern(token)
            elif args_len == 2:
                return pattern(token, stream)

    
def get_admissible_tokens(pattern):
    """
    Get the strings admissible for a pattern.
    None if all are
    """
    t = type(pattern)
    
    if t is str:
        return [pattern.lower()]
    
    elif t is Seq:

        t1 = type(pattern.list[0])
        if t1 is str:
            return [pattern.list[0].lower()]
            
    
    elif t is Or:
        result = []
        for sub_pattern in pattern.list:
            
            admissible = get_admissible_tokens(sub_pattern)
            if not admissible:
                return
            result += admissible
        
        return result
    
        
        
            
class BlockStatement(Node):
    """
    A possibly recursive node tree in an AST.
    
    Subclass it with begin and end member and optionally a header.
    """
    def print_tree(self, depth=0):
        """
        Print as a tree.
        """
        indent = ' ' * (depth * 2)
        print(indent, self.__class__.__name__)
        
        if self.header:
            print(indent, ' header')
            for token in self.header:
                print(indent, ' ', ' ', token)
        
        for token in self.get_body():
            
            if not type(token) is Token:
                token.print_tree(depth + 1)
            else:
                print(indent, ' ', token)


class Statement(Node):
    """
    A statement node with no recursion.
    """
    def get_tokens(self):
        "An iterator on tokens that skips whitespaces and comments"
        return self.get_children()
    
    def print_tree(self, depth=0):
        """
        Print as a tree.
        """
        indent = ' ' * (depth * 2)
        print(indent, self.__class__.__name__)
        
        for token in self.children:
            token.print_tree(depth+1)


class Term(Node):
    """
    A node without ... operator
    
    class Call(Term):
        match = Seq(Name, Parenthesis)
    
    """
    @staticmethod
    def match_term(node, token, stream):
        return Node._match(node.match, token, stream)
    

class TokenIterator:
    """
    Skip whitespaces and comments.
    """
    def __init__(self, tokens):
        self.tokens = iter(tokens)

    def __iter__(self):
        return self

    def __next__(self):
        token = None
        while not token:
            token = next(self.tokens)
            
            if not type(token) is Token:
                break
            
            if token.is_whitespace():
                token = None
            elif token.is_comment():
                token = None
        
        return token
    
    def __repr__(self):
        return str(self.tokens)
    

class Lookahead:
    """
    Transform a stream into a lookahead stream.
    """
    def __init__(self, stream):
        self.stream = iter(stream)
        self.lookahead = False
        self.tokens = []
        self.index = 0
        
        
    def __iter__(self):
        return self

    def __next__(self):
        if self.lookahead:
            item = None
            if self.tokens and self.index < len(self.tokens):
                item = self.tokens[self.index]
            else:
                item = self.stream.__next__()
                self.tokens.append(item)
            
            self.index += 1
            return item
        else:
            if self.tokens:
                return self.tokens.pop(0)
            else:
                return self.stream.__next__()

    def look_next(self):
        "Use lookahead to preview next token without consuming it"
        self.start_lookahead()
        try:
            result = next(self)
            return result
        finally:
            self.stop_lookahead()
        

    def move_to(self, tokens):
        """
        Move the cursor just after a token having text
        
        tokens can be a test or a list of text, it will go to one of these tokens
        
        @return the token matched
        """
        list_text = []
        if type(tokens) is list:
            list_text = tokens
        else:
            list_text.append(tokens)
        
        try:
            while True:
                token = self.__next__()
                if token in list_text:
                    return token
                if token.type in list_text:
                    return token
            return None
        except:
            return None

    def start_lookahead(self):
        
        if self.lookahead:
            raise RuntimeError("Lookahead : cannot start a lookahead when one is already open")
        
        self.lookahead = True
        self.index = 0

    def stop_lookahead(self):
        self.lookahead = False

    def stop_lookahead_and_consume(self):
        """Stop lookahead and consume what has been seen"""
        self.lookahead = False
        result = self.tokens[:self.index]
        self.tokens = self.tokens[self.index:]
        return result

    def __repr__(self):
        
        return 'Lookahead(lookahead=' + str(self.lookahead) + ', index=' + str(self.index) + ', tokens=' + str(self.tokens) + ')'


class StatementFilter:
    """
    Split a token stream into statements and blocks.
    """
    def __init__(self, statements=[]):
        
        # recognized statements blocks
        self.raw_statements = statements
        self.groups = []
        self.statements = []
        self.terms = []
        
        if type(statements) is list:
            
            self.groups = [b for b in statements if issubclass(b, BlockStatement)]
            self.statements = [s for s in statements if issubclass(s, Statement)]
            self.terms = [s for s in statements if issubclass(s, Term)]
        
        # current node context (for contextual parsing on an existing tree)
        # do not confuse with stack
        self.node_context = []
        
        # current block stack
        self.stack = []
        self.statement = None
        self.in_header = False
        self.in_body = False
        
        self.comments = []
        
        # try to speed things by caching some data...
        self.__text_to_statements = defaultdict(list)
        self.__other_statements = []
        
        self.__text_to_blocks = defaultdict(list)
        self.__other_blocks = []

        self.__text_to_terms = defaultdict(list)
        self.__other_terms = []
        
        self._precalculate()
        
    def _precalculate(self):
        """
        Calculate map 'token text' to the set of applicable begins...
        """
        # calculate map
        for statement in self.statements:
            admissibles = get_admissible_tokens(statement.begin)
            if not admissibles:
                self.__other_statements.append(statement)
            else:
                for admissible in admissibles:
                    self.__text_to_statements[admissible].append(statement)
#             print('get_current_statements', len(self.__text_to_statements), len(self.__other_statements))
            
        # calculate map first time
        for group in self.groups:
            
            admissibles = []
            if hasattr(group, 'header'):
                admissibles = get_admissible_tokens(group.header)
            else:
                admissibles = get_admissible_tokens(group.begin)
            if not admissibles:
                self.__other_blocks.append(group)
            else:
                for admissible in admissibles:
                    self.__text_to_blocks[admissible].append(group)
#             print('get_current_groups', len(self.__text_to_blocks), len(self.__other_blocks))

        # calculate map first time
        for term in self.terms:
            
            admissibles = get_admissible_tokens(term.match)
            if not admissibles:
                self.__other_terms.append(term)
            else:
                for admissible in admissibles:
                    self.__text_to_terms[admissible].append(term)
#             print('get_current_terms', len(self.__text_to_terms), len(self.__other_terms))
        
    
    def process(self, stream):
        """
        Group a token stream.
        stream must be a Lookahead stream.
        """
        for token in stream:
            group = self.process_token(token, stream)
            if group:
#                 print('    proces',  group)
                if type(group) is list:
                    for e in group:
                        yield e
                else:
                    yield group 
        
        
        # return trailing comments
        for token in self.comments:
            yield token

        # return non closed statement
        if self.statement:
            self.statement.on_end()
            yield self.statement
            
        # return non closed group
        if self.stack:
            self.stack[0].on_end()
            self._recurse_on_block(self.stack[0])
            yield self.stack[0]
        
        
    def _recurse_on_block(self, block):
        """
        Magic part...
        """
#         print('_recurse_on_block', block)     
        # we 'clone' self so that current state is unaffected
        self_clone = StatementFilter(self.raw_statements)
        
        self_clone.node_context = list(self.node_context)
        self_clone.node_context.append(block)
        
        # contextual parsing 
        # switch grammar depending on current block type 
        if type(self.raw_statements) is dict:
            
            _t = type(block)
            
            for matching_context in self.raw_statements:
                
                if matching_context == _t:
                    # {<node type> : [...], ...}
                    statements = self.raw_statements[matching_context]
                    self_clone.groups = [b for b in statements if issubclass(b, BlockStatement)]
                    self_clone.statements = [s for s in statements if issubclass(s, Statement)]
                    self_clone.terms = [s for s in statements if issubclass(s, Term)]
                    self_clone._precalculate()

                elif isinstance(matching_context, NodePath) and matching_context.match(self_clone.node_context):
                    
                    # XPath on nodes
                    statements = self.raw_statements[matching_context]
                    self_clone.groups = [b for b in statements if issubclass(b, BlockStatement)]
                    self_clone.statements = [s for s in statements if issubclass(s, Statement)]
                    self_clone.terms = [s for s in statements if issubclass(s, Term)]
                    self_clone._precalculate()
                
        # recurse on inner body
        # we assume here that the current block is ok so we do not need 
        # to reparse the begin part and the end part, only the inner body
        begin, inner_body, end = block._split_block()
        
        # rebuild the body 
        new_inner_nody = list(self_clone.process(Lookahead(inner_body)))

        # ugly but works better        
        self_clone = StatementFilter(self.raw_statements)
        self_clone.node_context = list(self.node_context)
        self_clone.node_context.append(block)
        
        # recurse also in begin/end
        for token in end:
            if isinstance(token, Node):
                self_clone._recurse_on_block(token)
        
        for token in begin:
            if isinstance(token, Node):
                self_clone._recurse_on_block(token)
        
        # et hop!
        block.children = begin + new_inner_nody + end
        
        
    def process_token(self, token, stream):

#         print('process_token', token, self.groups, self.statements, )        
        
        if isinstance(token, Node):
            # recurse
            self._recurse_on_block(token)
            
        
        # handle statements
        if self.statement:
            return self.process_current_statement(token, stream)
        
        term = self.try_match_term(token, stream)
        if term:
            # recurse also inside the matched term if needed
            for node in term.get_sub_nodes():
                self._recurse_on_block(node)
            
            # need it after...
            term.on_end()
            
            if self.stack:
                self.stack[-1].children.append(term)
                setattr(term, 'get_parent', weakref.ref(self.stack[-1]))
                return
            return term
        
        self.try_match_statement(token, stream)
        if self.statement:
            # wait for the end of the statement
            return None
                
        # hanlde ending of current element
        if self.stack:
            match = Node.match_end(self.stack[-1], token, stream) 
            if match:

                current_group = self.pop_group()
                current_group.children += match
                current_group.end_length = len(match)
                current_group.on_end()  # user callback
                
                # return last group
                if not self.stack:
                    return current_group
                else:
                    return None
                
        def has_header(group):
            return hasattr(group, 'header')

        def is_auto_recursive(group):
            auto_recursive = True  # default
            if hasattr(group, 'auto_recursive'):
                auto_recursive = getattr(group, 'auto_recursive')
            return auto_recursive
        
        if self.in_header and self.stack:
            
            current_group = self.stack[-1]
            
            if not is_auto_recursive(current_group):
                match = Node.match_header(current_group.__class__, token, stream)
                if match:
                    # match header and not auto_recursive : break
                    new_group = current_group.__class__()
                    
                    # @todo : remove
                    new_group.header_comments = [comment for comment in self.comments if comment.is_comment()]
                    # @todo : remove
                    new_group.header = list(match)
                    
                    new_group.header_comments_length = len(self.comments)
                    new_group.header_length = len(match)
                    
                    new_group.children = self.comments + match
                    self.comments =  []
                    
                    # break preceding
                    self.pop_group()
                    current_group.on_end()  # user callback
                    
                    # push current
                    self.push_group(new_group)
                    if len(self.stack) == 1:
                        return current_group
                    else:
                        return
            
            # match begin : change state
            match = Node.match_begin(current_group.__class__, token, stream)
            if match:
                current_group.begin_length = len(match)
                
                current_group.children += match
                self.in_header = False
                return
            
            # else put token in header
            
            # @todo : remove
            current_group.header.append(token)
            
            current_group.header_length += 1
            current_group.children.append(token)
            return
        
        # hanlde begin of groups
        for group in self.get_current_groups(token):
            
            match = None
            
            if has_header(group):
                match = Node.match_header(group, token, stream)
                if match:
                    self.in_header = True
            else:
                match = Node.match_begin(group, token, stream)

            if match:
                
                current_group = group()
                
                current_group.header_comments_length = len(self.comments)
                
                # @todo : remove
                current_group.header_comments = self.comments
                current_group.children = self.comments + match
                #print('match begin', current_group)
                self.comments = []
                if has_header(group):
                    
                    # @todo : remove
                    current_group.header = list(match)
                
                    current_group.header_length = len(match)
                else:
                    current_group.begin_length = len(match)
                
                auto_recursive = is_auto_recursive(group)
                
                if self.stack:
                    if auto_recursive:
                        self.stack[-1].children.append(current_group)
                        setattr(current_group, 'get_parent', weakref.ref(self.stack[-1]))
                    else:
                        index = 0 
                        for openned in self.stack:
                            if openned.__class__ == group:
                                break
                            index += 1    
                        
                        # break the recusion due to auto_recursive = true
                        previous = self.stack[index]
                        self.stack = self.stack[:index]
                        if index == 0:
                            self.push_group(current_group)
                            return previous
                        
               
                self.push_group(current_group)
                return None
        
        if self.stack:
            self.stack[-1].children.append(token)
            return
        
        if token.is_comment() or (token.is_whitespace() and self.comments):
            self.comments.append(token)
            return None
        elif not token.is_whitespace() and token.text:
            # clean comments if something is between
            if self.comments:          
                result = self.comments + [token]
                self.comments = []
                return result
            
        return token

    def process_current_statement(self, token, stream):
        # we have a statement ongoing
        
        # match end
        match = Node.match_end(self.statement, token, stream)
        if match:
            
            #print('match end', self.statement)
            if self.statement.consume_end:
                self.statement.children += self.comments
                self.comments = []
                self.statement.end_length = len(match)
                self.statement.children += match

            self.statement.on_end()  # user callback
            result = self.statement
            self.statement = None
            
            if self.stack:
                self.stack[-1].children.append(result)
                setattr(result, 'get_parent', weakref.ref(self.stack[-1]))
                # we are in a block so we continue the mission
                return None
            else:
                return result
        else:
            
            # does a begin stop the current statement ?
            def is_stopped_by_other(group):
                stopped_by_other_statement = False  # default
                if hasattr(group, 'stopped_by_other_statement'):
                    stopped_by_other_statement = getattr(group, 'stopped_by_other_statement')
                return stopped_by_other_statement
            
            if is_stopped_by_other(self.statement):
                
                # context saving
                _save = self.statement 
                self.statement = None
                self.try_match_statement(token, stream)
                
                if self.statement:
                    # matched : stop current statement
                                        
                    _save.on_end()  # user callback
                
                    if self.stack:
                        self.stack[-1].children.append(_save)
                        setattr(_save, 'get_parent', weakref.ref(self.stack[-1]))
                        # we are in a block so we continue the mission
                        return None
                    else:
                        return _save
                
                # not matched restore context, continue as usual
                self.statement = _save
            
            if token.is_comment() or (token.is_whitespace() and self.comments):
                self.comments.append(token)
            else:
                # maybe we should check that there is no whitespace ...
                self.statement.children += self.comments
                self.comments = []
                self.statement.children.append(token)
                
            return None
        
    def try_match_statement(self, token, stream):
        # search for statement beginning
        
        for statement in self.get_current_statements(token):
            
            match = Node.match_begin(statement, token, stream)
            if match:
                
#                 print('match begin', statement)
                self.statement = statement()
                
                self.statement.header_comments_length = len(self.comments)
                
                # @todo : remove
                self.statement.header_comments = self.comments
                
                self.statement.begin_length = len(match)
                self.statement.children = self.comments + match
                self.comments = []
                # @todo : remove
                self.statement.header = Node._last_matched_header
                Node._last_matched_header = []
                
#                 print(self.statement.children)
                break
                
    def try_match_term(self,  token, stream):
        
        # search for statement beginning
        for statement in self.get_current_terms(token):
            
            match = Term.match_term(statement, token, stream)
            if match:
        
                result = statement()
                
                result.header_comments_length = len(self.comments)
                
                result.begin_length = len(match)
                result.children = self.comments + match
                self.comments = []
                
                return result

    def push_group(self, group):
        self.stack.append(group)

    def pop_group(self):
        return self.stack.pop()

#     def stack_has_group(self, auto_recursive, ):

    def get_current_statements(self, token):
        
        
        # yield in map
        if token.text:
            return self.__text_to_statements[token.lower_text] + self.__other_statements
        else:
            return self.__other_statements

    def get_current_groups(self, token):

        # yield in map
        if token.text:
            return self.__text_to_blocks[token.lower_text] + self.__other_blocks
        else:
            return self.__other_blocks
        
    def get_current_terms(self, token):
        # yield in map
        if token.text:
            return self.__text_to_terms[token.lower_text] + self.__other_terms
        else:
            return self.__other_terms
        

import inspect
def get_subclass(_class): 
    if hasattr(_class, '__cached_sub_classes'):
        return getattr(_class, '__cached_sub_classes')
    
    result = inspect.getmembers(_class, predicate=inspect.isclass)[:-1]
    setattr(_class, '__cached_sub_classes', result)
    return result
