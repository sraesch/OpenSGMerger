# include <OpenSG/OSGConfig.h>
# include <OpenSG/OSGSceneFileHandler.h>
# include <OpenSG/OSGConfigured.h>
# include <OpenSG/OSGMaterial.h>
# include <OpenSG/OSGDistanceLOD.h>
# include <OpenSG/OSGGeometry.h>
# include <OpenSG/OSGGeoFunctions.h>
# include <OpenSG/OSGTransform.h>
# include <OpenSG/OSGMaterialGroup.h>
# include <OpenSG/OSGChunkMaterial.h>
# include <OpenSG/OSGSimpleMaterial.h>
# include <OpenSG/OSGMaterialChunk.h>
# include <OpenSG/OSGStringAttributeMap.h>
# include <OpenSG/OSGMetaDataAttachment.h>

#include <iostream>
#include <array>
#include <vector>
#include <string>
#include <cctype>
#include <fstream>
#include <stdexcept>

namespace
{
    const std::array<std::string, 2> allowedExt = {"osb", "osg"};

    void printUsage()
    {
        std::cout << "USAGE: OpenSGMerger OUTPUT INPUT1 ...\n";
        std::cout << "Merges the input files to one single OpenSG file which is dumped as OUTPUT.\n";
    }

    std::string getExtension(const std::string &fname)
    {
        const auto pos = fname.find_last_of('.');
        if(pos == std::string::npos)
            throw std::invalid_argument("");

        auto ext = fname.substr(pos + 1);

        for(auto &ch: ext)
            ch = std::tolower(ch);

        return ext;
    }

    osg::NodePtr loadFile(const std::string &fname)
    {
        std::ifstream in(fname);
        if(!in)
            throw std::invalid_argument("Couldn't open file " + fname);

        const std::string ext = getExtension(fname);
        if(std::find(allowedExt.begin(), allowedExt.end(), ext) == allowedExt.end())
            throw std::invalid_argument("Unknown extension: " + ext);

        osg::NodePtr node = OSG::SceneFileHandler::the().read(in, ext.c_str());
        if(node == OSG::NullFC)
            throw std::ios::failure("Couldn't open the given input file");

        return node;
    }
}


int main(int argc, char *argv[])
{
    // check arguments
    if(argc < 3)
    {
        printUsage();
        return -1;
    }

    const std::string outputFile = argv[1];
    const std::vector<std::string> inFiles = {argv + 2, argv + argc};

    // print short info
    std::cout << "[INFO]: Output file=" << outputFile << std::endl;
    std::cout << "[INFO]: Input files:\n";
    for(const auto& inFile: inFiles)
        std::cout << "[INFO]: Input file=" << inFile << std::endl;

    // initialize OpenSG
    OSG::osgInit(0, 0);

    // create root node
    osg::NodePtr rootNode = osg::Node::create();
    rootNode->setCore(osg::Group::create());

    // load input files
    for(const std::string& fname: inFiles)
    {
        std::cout << "[INFO]: Read input file " << fname << "\n";

        try
        {
            osg::NodePtr node = loadFile(fname);

            rootNode->addChild(node);
        }
        catch(const std::exception &e)
        {
            std::cerr << "[ERROR]: Failed to load file '" << fname << "' !!!\n";
        }
    }

    // write output data
    std::cout << "[INFO]: Write output file...\n";
    {
        std::ofstream out(outputFile);
        if(!out)
        {
            std::cerr << "[ERROR]: Failed to write output data!!!\n";
            return -1;
        }

        OSG::SceneFileHandler::the().write(rootNode, out, "osb", false);
    }


    return 0;
}
