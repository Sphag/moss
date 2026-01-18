// Tests for example_tool

#include <gtest/gtest.h>

// Example test
TEST(ExampleToolTest, BasicTest)
{
    EXPECT_EQ(1 + 1, 2);
}

TEST(ExampleToolTest, StringTest)
{
    std::string test = "hello";
    EXPECT_EQ(test, "hello");
}
