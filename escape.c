/* from Coding/util/unescape/%xx/foo.c, 2013-12-01 */

/*
 * Copyright 2013 Chen Ruichao <linuxer.sheep.0x@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdio.h>
#include <ctype.h>

char C;

int main(void)
{
    while( scanf("%c", &C) != EOF ) {
        if( C=='\r' || C=='\n' )
            break;
        if( isalnum(C) || C=='.' || C=='_' )
            putchar(C);
        else if( C==' ' )
            putchar('+');
        else printf("%%%02hhX", C);
    }
    // putchar('\n');
    if(ferror(stdin)) {
        fputs("ouch, an error occured!", stderr);
        return 2;
    }
    return 0;
}
