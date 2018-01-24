#include <stdio.h>
#include <string.h>
#include "CmdLineParser.h" 
#include "CmdLineSpec.h" 
#include "Cmdline.h" 

#pragma warning( disable : 4996 )
 
char *progname = 0;
char *szVersion = "1.0";
 
extern std::map<std::string, OptionSpec> cmdlineLexingSpecs;
void usage(FILE *fp);
void version(FILE *fp);
 
int main (int argc, char *argv[])
{
    progname = argv[0];
    std::map<std::string, OptionSpec> specs;

    specs["h"] = OptionSpec(false, "this help");
    specs["v"] = OptionSpec(false, "version");
    specs["filename"] = OptionSpec(true, "input filename");
    specs["bbbb"] = OptionSpec(false);
    // specs["y"] = OptionSpec(false);
    CmdLineSpec cls(specs);
    cmdlineLexingSpecs = specs;

    pcldebug = 0;
    CmdLineParser clp(argc, argv, cls);
    // char *fake[] = {progname};
    // CmdLineParser clp(1, fake, cls);
    Cmdline cmdline = clp.parse();
    if (!cmdline.isValid())
    {
        return 1;
    }

    FILE *ifp = stdin;
 
    if (cmdline.hasOption("h"))
    {
        std::string blurb = progname;
        blurb += " options filename\nreads filename\n"
                 "and does things\n";
        cls.help(blurb, stdout);
        return 0;
    }

    if (cmdline.hasOption("v"))
    {
        version(stdout);
        return 0;
    }

    if (cmdline.numArguments() > 0)
    {
        ifp = fopen(cmdline.getArgument(0).c_str(), "rt");
        if (ifp == 0)
        {
            perror (progname);
            return 1;
        }
    }
 
    if (ifp != stdin)
        fclose(ifp);
 
    return 0;
}
 
void usage(FILE *fp)
{
    version(fp);
    fprintf(fp, "%s\n -h? -v? filename\n"
                    "reads input .\n"
                    "options:\n"
                    "-v\n"
                    "    version. Writes version and exits.\n"
                    "-h\n"
                    "    help. Writes usage text and exits.\n"
                    "filename\n"
                    "    filename. Input filename. If omitted, stdin is read.\n",
                    progname);
}
 
void version(FILE *fp)
{
    fprintf(fp, "%s version %s\n", progname, szVersion);
}
