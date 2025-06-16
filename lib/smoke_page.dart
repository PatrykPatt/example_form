import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'smoke_cubit.dart';
import 'widgets/form_widgets.dart';

class SmokePage extends StatelessWidget {
  const SmokePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Demo Form', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey,
      ),
      body: BlocConsumer<SmokeCubit, SmokeState>(
        listenWhen: (previous, current) => previous.error != current.error && current.error != null,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state.formSubmitted) {
            return _buildFormSubmitted(context);
          }
          
          return _buildForm(context, state);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, SmokeState state) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0 + bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Czy Palisz papierosy?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  onPressed: () => context.read<SmokeCubit>().setSmoker(true),
                  label: const Text('Tak'),
                  backgroundColor: state.isSmoker == true ? Colors.green.shade800 : Colors.green,
                ),
                const SizedBox(width: 30),
                FloatingActionButton.extended(
                  onPressed: () => context.read<SmokeCubit>().setSmoker(false),
                  label: const Text('Nie'),
                  backgroundColor: state.isSmoker == false ? Colors.red.shade800 : Colors.red,
                ),
              ],
            ),
            
            if (state.isSmoker == true) _buildSmokerSection(context, state),
            
            if (state.isSmoker == false) _buildNonSmokerSection(context, state),
            
            if (state.showCommentsInput) ...[
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),
              
              Text(
                state.isSmoker == true && state.hasHealthIssues == true ? 
                  'Dlaczego nie chcesz rzucić palenia?' : 
                  state.isSmoker == true ? 
                    'Dlaczego nie chcesz rzucić palenia?' : 
                    'Uwagi na temat ludzi palących papierosy:',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: state.commentsHintText,
                ),
                onChanged: (value) => context.read<SmokeCubit>().setComments(value),
                controller: TextEditingController(text: state.comments)..selection = 
                  TextSelection.fromPosition(TextPosition(offset: state.comments?.length ?? 0)),
              ),
            ],
            
            if (state.isFormComplete) ...[
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: state.isLoading ? null : () => context.read<SmokeCubit>().submitForm(),
                  child: state.isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Wyślij'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSmokerSection(BuildContext context, SmokeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Divider(),
        const SizedBox(height: 20),
        
        const Text(
          'Liczba papierosów dziennie:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        FormWidgets.buildSlider(
          value: (state.cigarettesPerDay ?? 0).toDouble(),
          min: 0.0,
          max: 60.0,
          onChanged: (value) => context.read<SmokeCubit>().setCigarettesPerDay(value.round()),
        ),
        
        const SizedBox(height: 30),
        
        const Text(
          'Od ilu lat palisz:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        FormWidgets.buildSlider(
          value: (state.yearsSmoked ?? 0).toDouble(),
          min: 0.0,
          max: 60.0,
          onChanged: (value) => context.read<SmokeCubit>().setYearsSmoked(value.round()),
        ),
        
        const SizedBox(height: 30),
        
        const Text(
          'Czy masz problemy zdrowotne związane z paleniem?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        FormWidgets.buildBooleanRadioGroup(
          value: state.hasHealthIssues,
          onChanged: (value) => context.read<SmokeCubit>().setHasHealthIssues(value!),
        ),
        
        if (state.hasHealthIssues == true) ...[
          const SizedBox(height: 30),
          const Text(
            'Czy chcesz rzucić palenie?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          FormWidgets.buildBooleanRadioGroup(
            value: state.wantsToQuit,
            onChanged: (value) => context.read<SmokeCubit>().setWantsToQuit(value!),
          ),
          
          if (state.wantsToQuit == true) ...[
            const SizedBox(height: 30),
            const Text(
              'Planowana data rzucenia palenia:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FormWidgets.buildDatePicker(
              context: context,
              selectedDate: state.quitDate,
              onDateSelected: (date) => context.read<SmokeCubit>().setQuitDate(date),
            ),
          ],
        ],
        
        if (state.hasHealthIssues == false) ...[
          const SizedBox(height: 30),
          const Text(
            'Świadomość negatywnych skutków palenia:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          FormWidgets.buildAwarenessRadioGroup(
            value: state.awarenessOfEffects,
            onChanged: (value) => context.read<SmokeCubit>().setAwarenessOfEffects(value!),
          ),
          
          if (state.awarenessOfEffects == false) ...[
            const SizedBox(height: 20),
            const Text(
              'Skutki palenia papierosów:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FormWidgets.buildSmokingEffectsList(state.smokingEffects, state.error),
          ],
        ],
      ],
    );
  }
  
  Widget _buildNonSmokerSection(BuildContext context, SmokeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Divider(),
        const SizedBox(height: 20),
        
        const Text(
          'Świadomość negatywnych skutków palenia:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        FormWidgets.buildAwarenessRadioGroup(
          value: state.awarenessOfEffects,
          onChanged: (value) => context.read<SmokeCubit>().setAwarenessOfEffects(value!),
        ),
        
        if (state.awarenessOfEffects == false) ...[
          const SizedBox(height: 20),
          const Text(
            'Skutki palenia papierosów:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          FormWidgets.buildSmokingEffectsList(state.smokingEffects, state.error),
        ],
      ],
    );
  }
  
  Widget _buildFormSubmitted(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
          const SizedBox(height: 20),
          const Text(
            'Formularz został wysłany!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Dziękujemy za wypełnienie ankiety.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            onPressed: () => context.read<SmokeCubit>().resetForm(),
            child: const Text('Wypełnij ponownie'),
          ),
        ],
      ),
    );
  }
}