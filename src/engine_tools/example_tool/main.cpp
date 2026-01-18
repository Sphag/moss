// Example CLI Tool for Moss Engine
// This is a template for creating CLI tools

#include <iostream>

int main(int argc, char* argv[])
{
    std::cout << "Moss Engine Example CLI Tool" << std::endl;
    std::cout << "Arguments: " << argc - 1 << std::endl;
    
    for(int i = 1; i < argc; ++i)
    {
        std::cout << "  [" << i << "] " << argv[i] << std::endl;
    }
    
    return 0;
}
