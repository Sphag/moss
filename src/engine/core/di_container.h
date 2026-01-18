#pragma once

#include <memory>
#include <cassert>
#include <unordered_map>
#include <typeindex>
#include <functional>
#include <vector>
#include <any>


namespace moss::core {

    class di_container final {
        public:
            template <typename T>
            void register_factory(std::function<std::shared_ptr<T>(di_container&)> factory) {
                std::type_index type_index = std::type_index(typeid(T));
                m_factories[type_index] = [factory](di_container& container) -> std::any {
                    return factory(container);
                };
            }


            template <typename T>
            void register_singleton(std::shared_ptr<T> instance) {
                m_instances[std::type_index(typeid(T))] = instance;
            }


            template <typename T>
            std::shared_ptr<T> resolve() {
                return std::static_pointer_cast<T>(resolve_internal(std::type_index(typeid(T))));
            }

        private:
            std::any register_internal(std::type_index type_index) {
                if (auto instance_iter = m_instances.find(type_index); instance_iter != m_instances.end()) {
                    return instance_iter;
                }

                for (std::type_index active_type : m_resolution_stack) {
                    if (active_type == type_index) {
                        // TODO add proper error handling
                        assert(false);
                    }
                }

                if (m_factories.find(type_index) == m_factories.end()) {
                    // TODO add proper error handling
                    assert(false);
                }

                m_resolution_stack.push_back(type_index);
                std::any instance = m_factories[type_index](*this);
                m_resolution_stack.pop_back();

                m_instances[type_index] = instance;
                return instance;
            }

        private:
            std::unordered_map<std::type_index, std::function<std::any(di_container&)>> m_factories;
            std::unordered_map<std::type_index, std::any> m_instances;
            std::vector<std::type_index> m_resolution_stack;
    };
}