## Directory Structure

```
.
├── docs
├── external
│   └── libmcu
├── include
├── ports
│   └── esp-idf
├── src
└── tests
    ├── fakes
    ├── mocks
    ├── runners
    ├── src
    └── stubs
```

| Directory | Desc.                                                               |
| --------- | ------------------------------------------------------------------- |
| docs      | Documentation                                                       |
| external  | Third-party libraries or SDK. e.g. ESP-IDF                          |
| include   | The project header files                                            |
| ports     | Wrappers or glue code to bring third-party drivers into the project |
| src       | Application code. No hardware or platform-specific code             |
| tests     | Test codes                                                          |

