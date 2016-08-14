---
layout: post
title: Context Switch on the ARM Cortex-M0
tags: embedded, cortex-m
---

I have written a simple round-robin scheduler ([available on GitHub][1]) for the
ARM Cortex-M0 (ARMv6-M) CPU to understand the context switch mechanism. This
article is a short summary of its principle.

The same approach is used by many RTOSes and is well described in
[The Definitive Guide to ARM® Cortex®-M0 and Cortex-M0+ Processors][2] by
Joseph Yiu.

[![Round-robin scheduler][intro]][intro]

<!--more-->

## Background

The processor has two separate stack pointer which can be accessed through banked
``SP`` register: **Main Stack Pointer** (MSP) which is the default one after
startup and **Process Stack Pointer** (PSP) which can be optionally used.

The processor supports multiple modes:

  - The default mode is the **Privileged Thread Mode**. It is possible to switch
    stack to PSP in this mode
  - The Privileged mode can be switched to **Unprivileged Thread Mode** which has
    certain register and memory access restrictions
  - Exceptions and interrupts are handled in the **Handler Mode** which uses the
    MSP stack.

In this application, tasks run in the Unprivileged Thread Mode with PSP and
kernel runs in the Handler Mode with MSP. This allows stack separation
between the kernel and tasks (which simplifies the context switch procedure) and
prevents tasks from accessing important registers and affecting the kernel.

## Context Switch

The context switch happens in an interrupt handler. Once an interrupt occurs,
the NVIC hardware automatically stacks an **exception frame** (registers
``xPSR``, ``PC``, ``LR``, ``r12`` and ``r3-r0``) onto the Process Stack (PSP)
and branches to the interrupt handler routine in Handler Mode (which uses the
Main Stack).

The context switch routine has to:

  - Manually stack remaining registers ``r4-r11`` on the Process Stack
  - Save current task's PSP to memory
  - Load next task's stack pointer and assign it to PSP
  - Manually unstack registers ``r4-r11``
  - Call ``bx 0xfffffffD`` which makes the processor switch to Unprivileged
    Handler Mode, unstack next task's exception frame and continue on its ``PC``.

Exception frame saved by the NVIC hardware onto stack:

[![Exception frame saved by NVIC][stack_nvic]][stack_nvic]

Registers saved by the software:

[![Registers saved by SW][stack_sw]][stack_sw]

## Performing the Context Switch

The context switch could be performed by the ``SysTick_Handler`` with a SysTick
timer configured to fire interrupts periodically:

[![Context switch performed by SysTick][systick_only]][systick_only]

This approach would however not work with other interrupts (peripheral interrupt
for example). The ``SysTick_Handler`` would stack registers affected by the
peripheral IRQ handler and unstack task's registers, resulting in undefined
behavior of both tasks and peripheral interrupt handler:

[![Context switch performed by SysTick - problem with IRQ][systick_irq_problem]][systick_irq_problem]

The solution is simple - the [SysTick_Handler][3] with the highest priority
only selects the next task to be run and triggers PendSV interrupt.
The [PendSV_Handler][4] with the lowest priority performs the actual
context switch once all interrupt requests with higher priority have been
handled:

[![Context switch scheduled by SysTick and performed by PendSV][systick_pendsv]][systick_pendsv]

The ``PendSV_Handler`` is written in pure assembly. The code relies on a fact
that the task's stack pointer is the first element of the [os_task_t][5]
structure - the structure's address corresponds to the address of its first
element according to C language specification.

## Task Initialization

Each task is defined by its handler function and stack. The initialization phase
of task's stack must ensure that the first 64 bytes (16 words) form a valid
exception frame. It is neccessary to store at least the default value of three
registers:

  - ``xPSR`` to ``0x01000000`` (the defaul value)
  - ``PC`` to the handler function
  - ``LR`` to ``0xFFFFFFFD`` (EXC_RETURN - unprivileged thread mode with the
    Process Stack)

The actual function [os_task_init][6] stores values for registers ``r0-r12`` as
well for debugging purposes.

## Startup

The startup phase has to configure SysTick and PendSV interrupt levels,
initialize the SysTick timer to fire interrupts periodically and start the
first task.

As the microcontroller starts in Privileged Thread Mode with Main Stack it is
neccessary to switch to Unprivileged mode with Process Stack. This is done by
writing to the ``CONTROL`` register followed by ``ISB`` instruction.

The [os_start][7] function is written without inline assembly thanks to
functions and intrinsics provided by the CMSIS library.

## Example

An [example][8] runs three tasks (which are switched every second). All tasks
blink the onboard LED with different frequency.

The example can be run on STM32F030R8 Nucleo board and requires [STM32Cube][9]
software pack which has to be present in the [lib][10] directory.

The provided Makefile requires GCC compiler and OpenOCD. See
[README][11] for more information about compilation and flashing.

## Compatibility

The SysTick timer and Privileged mode are optional features of the ARMv6-M
architecture. They are however supported by vast majority of microcontrollers.

The code relies on standard [CMSIS library][12] by ARM which is usually
distributed by microcontroller vendors. The library provides functions and
intrinsics for accessing features of the ARM Cortex-M core.

[1]: https://github.com/adamheinrich/os.h/tree/blog_2016_07
[2]: http://store.elsevier.com/The-Definitive-Guide-to-ARM%C2%AE-Cortex%C2%AE-M0-and-Cortex-M0+-Processors/Joseph-Yiu/isbn-9780128032770/
[3]: https://github.com/adamheinrich/os.h/blob/blog_2016_07/src/os.c#L104
[4]: https://github.com/adamheinrich/os.h/blob/blog_2016_07/src/os_pendsv_handler.s
[5]: https://github.com/adamheinrich/os.h/blob/blog_2016_07/src/os.c#L8
[6]: https://github.com/adamheinrich/os.h/blob/blog_2016_07/src/os.c#L40
[7]: https://github.com/adamheinrich/os.h/blob/blog_2016_07/src/os.c#L82
[8]: https://github.com/adamheinrich/os.h/blob/blog_2016_07/examples/stm32f030x8/main.c
[9]: http://www.st.com/content/st_com/en/products/embedded-software/mcus-embedded-software/stm32-embedded-software/stm32cube-embedded-software.html?querycriteria=productId=LN1897
[10]: https://github.com/adamheinrich/os.h/tree/blog_2016_07/examples/lib
[11]: https://github.com/adamheinrich/os.h/blob/blog_2016_07/examples/stm32f030x8
[12]: http://www.arm.com/products/processors/cortex-m/cortex-microcontroller-software-interface-standard.php

[intro]: {{ site.baseurl }}/public/img/context-switch-on-the-arm-cortex-m0/os_intro.png
[stack_nvic]: {{ site.baseurl }}/public/img/context-switch-on-the-arm-cortex-m0/os_stack_nvic.png
[stack_sw]: {{ site.baseurl }}/public/img/context-switch-on-the-arm-cortex-m0/os_stack_sw.png
[systick_only]: {{ site.baseurl }}/public/img/context-switch-on-the-arm-cortex-m0/os_systick_onyly.png
[systick_irq_problem]: {{ site.baseurl }}/public/img/context-switch-on-the-arm-cortex-m0/os_systick_irq_problem.png
[systick_pendsv]: {{ site.baseurl }}/public/img/context-switch-on-the-arm-cortex-m0/os_systick_pendsv.png